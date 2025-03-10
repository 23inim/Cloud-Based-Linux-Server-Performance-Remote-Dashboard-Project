using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers;

[ApiController]
[Route("[controller]")]
public class StressngController : ControllerBase {

    [HttpGet(Name = "GetLastStressngMSG")]
    public ActionResult<string> GetLastStressngMSG()
    {
        return SNGService.Instance.getLastMessage();
    }

    [HttpGet("GetHistory")]
    public ActionResult<List<Status>> GetHistory()
    {
        return StatusService.Instance.getHistory();
    }

    [HttpPost(Name = "ahh")] 
    public ActionResult Post(StressParam param)
    {
        return  SNGService.Instance.StartNewTest(param.duration, param.type) ? Ok() : Conflict();
    }
}