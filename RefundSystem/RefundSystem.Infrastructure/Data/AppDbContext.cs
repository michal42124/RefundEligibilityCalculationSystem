using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RefundSystem.Infrastructure.Data;

using Microsoft.EntityFrameworkCore;
using RefundSystem.Core.Entities;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Citizen> Citizens => Set<Citizen>();
    public DbSet<MonthlyIncome> MonthlyIncomes => Set<MonthlyIncome>();
    public DbSet<RefundRequest> RefundRequests => Set<RefundRequest>();
    public DbSet<MonthlyBudget> MonthlyBudgets => Set<MonthlyBudget>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Citizen>(entity =>
        {
            entity.HasKey(e => e.CitizenId);
            entity.Property(e => e.IdNumber).IsRequired().HasMaxLength(20);
            entity.Property(e => e.FirstName).IsRequired().HasMaxLength(50);
            entity.Property(e => e.LastName).IsRequired().HasMaxLength(50);
            entity.HasIndex(e => e.IdNumber).IsUnique();
        });

        modelBuilder.Entity<MonthlyIncome>(entity =>
        {
            entity.HasKey(e => e.IncomeId);
            entity.Property(e => e.IncomeAmount).HasColumnType("decimal(10,2)");
            entity.HasOne(e => e.Citizen)
                  .WithMany(c => c.MonthlyIncomes)
                  .HasForeignKey(e => e.CitizenId);
        });

        modelBuilder.Entity<RefundRequest>(entity =>
        {
            entity.HasKey(e => e.RequestId);
            entity.Property(e => e.Status).IsRequired().HasMaxLength(50);
            entity.Property(e => e.ApprovedAmount).HasColumnType("decimal(10,2)");
            entity.Property(e => e.CalculatedAmount).HasColumnType("decimal(10,2)");
            entity.HasOne(e => e.Citizen)
                  .WithMany(c => c.RefundRequests)
                  .HasForeignKey(e => e.CitizenId);
        });

        modelBuilder.Entity<MonthlyBudget>(entity =>
        {
            entity.HasKey(e => e.BudgetId);
            entity.Property(e => e.TotalBudget).HasColumnType("decimal(12,2)");
            entity.Property(e => e.UsedBudget).HasColumnType("decimal(12,2)");
            entity.Ignore(e => e.AvailableBudget); // Computed property
        });
    }
}
