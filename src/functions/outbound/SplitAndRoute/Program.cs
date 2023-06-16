using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var serviceBusConnectionString = "samplecomp-sb-dev.servicebus.windows.net";//Environment.GetEnvironmentVariable("SERVICEBUS_ENDPOINT");
var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
       .ConfigureServices(builder =>
       {
           builder.AddSingleton((s) => {
               return new ServiceBusClient(serviceBusConnectionString, new DefaultAzureCredential(), new ServiceBusClientOptions() { TransportType = ServiceBusTransportType.AmqpTcp });
           });
       })
    .Build();

host.Run();


/*
 *    var serviceBusConnectionString = Environment.GetEnvironmentVariable("SERVICEBUS_ENDPOINT");
            if (string.IsNullOrEmpty(serviceBusConnectionString))
            {
                throw new InvalidOperationException(
                    "Please specify a valid ServiceBusConnectionString in the Azure Functions Settings or your local.settings.json file.");
            }

            //using AMQP as transport
            builder.Services.AddSingleton((s) => {
                return new ServiceBusClient(serviceBusConnectionString, new ServiceBusClientOptions() { TransportType = ServiceBusTransportType.AmqpTcp });
            });
 */

/*
 * var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices(builder =>
    {
        builder.AddTransient<IUserService, UserService>();
        builder.AddTransient<ICompetitionService, CompetitionService>();
        builder.AddTransient<ICompetitionRepository, CompetitionRepository>();
    })
    .Build();

host.Run();
 * 
 */ 