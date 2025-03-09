using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers;

[ApiController]
[Route("[controller]")]
public class StressngController : ControllerBase {

    [HttpGet(Name = "GetLastStressngMSG")]
    public ActionResult<string> Get()
    {
        return  SNGService.Instance.getLastMessage();
    }
}