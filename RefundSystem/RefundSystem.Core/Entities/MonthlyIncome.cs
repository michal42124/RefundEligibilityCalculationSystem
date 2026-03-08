
namespace RefundSystem.Core.Entities;

public class MonthlyIncome
{
    public int IncomeId { get; set; }
    public int CitizenId { get; set; }
    public int TaxYear { get; set; }
    public int Month { get; set; }
    public decimal IncomeAmount { get; set; }

    public Citizen Citizen { get; set; } = null!;
}
