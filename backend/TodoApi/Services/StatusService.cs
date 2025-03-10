using System.Formats.Asn1;
using System.IO.Pipes;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.EntityFrameworkCore.Metadata.Conventions;
using TodoApi;

public sealed class StatusService
{
    private object lockObj = new object();

    private const string pipeIn = "../../bashscripts/status_pipe_out.fifo";

    private Thread thread;

    private static readonly Lazy<StatusService> lazy =
        new Lazy<StatusService>(() => new StatusService());

    public static StatusService Instance { get { return lazy.Value; } }

    private LinkedList<Status> history = new LinkedList<Status>();

    private StatusService()
    {
        Console.WriteLine("StatusService started");
        if (!File.Exists(pipeIn))
        {
            throw new Exception("pipe do not yet exist, start the bash services at least once before starting this service");
        }

        thread = new Thread(() =>
        {
            while (true)
            {
                try
                {
                    using (FileStream fs = new FileStream(pipeIn, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                    using (StreamReader reader = new StreamReader(fs))
                    {
                        var lastMessage = reader.ReadToEnd();
                        var values = lastMessage.Split(' ');

                        var status = new Status()
                        {
                            totalMem = float.Parse(values[0]),
                            usedMem = float.Parse(values[1]),
                            freeMem = float.Parse(values[2]),
                            totalSwap = float.Parse(values[3]),
                            usedSwap = float.Parse(values[4]),
                            freeSwap = float.Parse(values[5]),
                            cpuUsage = 100 - float.Parse(values[6]),
                            diskR = float.Parse(values[7]),
                            diskW = float.Parse(values[8]),
                            rxBytes = float.Parse(values[9]),
                            txBytes = float.Parse(values[10])
                        };

                        lock (lockObj)
                        {
                            history.AddLast(status);
                            if(history.Count() > 30)
                                history.RemoveFirst();

                        }
                    }
                } catch {
                    Console.WriteLine("Error: reading status");
                }
            }
        });
        thread.Start();
    }


    public List<Status> getHistory() {
        lock (lockObj){
            return history.ToList();
        }
    }

}