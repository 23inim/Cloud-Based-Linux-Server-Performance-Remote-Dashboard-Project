using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddJsonOptions(options => options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

StatusService.Instance.getHistory();
SNGService.Instance.getLastMessage();

#if DEBUG
// Configure the HTTP request pipeline.
    app.MapOpenApi();

    app.UseSwaggerUi(options =>
    {
        options.DocumentPath = "/openapi/v1.json";
    });


#endif

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
