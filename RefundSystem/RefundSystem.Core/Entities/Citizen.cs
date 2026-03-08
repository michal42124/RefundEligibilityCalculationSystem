
namespace RefundSystem.Core.Entities;

public class Citizen
{
    public int CitizenId { get; set; }
    public string IdNumber { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;

    public ICollection<MonthlyIncome> MonthlyIncomes { get; set; } = [];
    public ICollection<RefundRequest> RefundRequests { get; set; } = [];
}