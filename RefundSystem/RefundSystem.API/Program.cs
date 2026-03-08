using Microsoft.EntityFrameworkCore;
using RefundSystem.API.Hubs;
using RefundSystem.Core.Interfaces;
using RefundSystem.Infrastructure.Data;
using RefundSystem.Infrastructure.Services;

using QuestPDF.Infrastructure;


var builder = WebApplication.CreateBuilder(args);

// Services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Dependency Injection
builder.Services.AddScoped<IRefundService, RefundService>();
builder.Services.AddScoped<ICitizenService, CitizenService>();

// CORS לתמיכה ב-React
builder.Services.AddCors(options =>
    options.AddPolicy("ReactApp", policy =>
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials() // ← חשוב ל-SignalR
              ));


builder.Services.AddSignalR();
// הגדרת רישיון QuestPDF לשימוש חינמי
QuestPDF.Settings.License = QuestPDF.Infrastructure.LicenseType.Community;
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("ReactApp");
app.UseAuthorization();
app.MapControllers();
app.MapHub<BudgetHub>("/budgetHub"); 

app.Run();