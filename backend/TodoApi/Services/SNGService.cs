using System.Formats.Asn1;
using System.IO.Pipes;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;

public sealed class SNGService
{
    private string lastMessage = "";
    private object lockObj = new object();
    public bool testInProgress { private set; get; }

    private const string pipeIn  = "../../bashscripts/sng_pipe_out.fifo";
    private const string pipeOut = "../../bashscripts/sng_pipe_in.fifo";

    private Thread thread;

    private static readonly Lazy<SNGService> lazy =
        new Lazy<SNGService>(() => new SNGService());

    public static SNGService Instance { get { return lazy.Value; } }

    private SNGService()
    {
        Console.WriteLine("SNGService started");
        if (!File.Exists(pipeIn) && !File.Exists(pipeOut))
        {
            throw new Exception("pipe do not yet exist, start the bash services at least once before starting this service");
        }

        thread = new Thread(() =>{
            while (true)
            {
                using (FileStream fs = new FileStream(pipeIn, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                using (StreamReader reader = new StreamReader(fs))
                {
                    var lastMessage = reader.ReadToEnd();
                    Console.WriteLine(lastMessage);

                    lock (lockObj) {
                        this.lastMessage = lastMessage;
                        testInProgress = false;
                    }
                }
            }
        });
        thread.Start();
    }

    private static void Write(string msg) {
        using (FileStream fs = new FileStream(pipeOut, FileMode.Open, FileAccess.Write, FileShare.Read))
        using (StreamWriter writer = new StreamWriter(fs)) {
            writer.WriteLine(msg);
        }
    }

    public bool StartNewTest(int s) {
        lock (lockObj) {
            if (testInProgress) {
                return false;
            }

            testInProgress = true;
            Write($"--matrix 1 -t {s}s");
            return true;
        }
    }

    public string getLastMessage() {
        lock (lockObj) {
            return lastMessage;
        }
    }
}