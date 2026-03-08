import { useState, useEffect, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import StatusBadge from '../shared/StatusBadge';
import './RequestDetails.css';
import { getRequestById, processRequest, approveRequest, getBudget, getCitizenHistory, getCitizenIncomes } from '../../api';
import * as signalR from '@microsoft/signalr';

const RequestDetails = ({ requestId, onBack }) => {
  const queryClient = useQueryClient();
  const [result, setResult] = useState(null);
  const [availableBudgetBeforeApproval, setAvailableBudgetBeforeApproval] = useState(null);

  const { data: request, isLoading, isError } = useQuery({
    queryKey: ['request', requestId],
    queryFn: () => getRequestById(requestId).then(res => res.data),
    refetchOnWindowFocus: false,
    staleTime: Infinity,
  });

  const { data: incomes = [] } = useQuery({
    queryKey: ['incomes', request?.citizenId],
    queryFn: () => getCitizenIncomes(request.citizenId).then(res => res.data),
    enabled: !!request?.citizenId,
  });

  const { data: history = [] } = useQuery({
    queryKey: ['citizenHistory', request?.citizenId],
    queryFn: () => getCitizenHistory(request.citizenId).then(res =>
      res.data.filter(r => r.requestId !== requestId)
    ),
    enabled: !!request?.citizenId,
  });

  const { data: budgetData } = useQuery({
    queryKey: ['budget', requestId],
    queryFn: () => {
      const requestDate = new Date(request.requestDate);
      return getBudget(requestDate.getFullYear(), requestDate.getMonth() + 1).then(res => res.data);
    },
    enabled: request?.status === 'WaitingApproval',
    staleTime: 0,
  });

  useEffect(() => {
    if (budgetData !== undefined && budgetData !== null) {
      setAvailableBudgetBeforeApproval(budgetData);
    } else {
      setAvailableBudgetBeforeApproval(null);
    }
  }, [budgetData]);

  const processMutation = useMutation({
    mutationFn: () => processRequest(requestId).then(res => res.data),
    onSuccess: (data) => {
      setResult(data);
      if (data.result !== 'ERROR') {
        setAvailableBudgetBeforeApproval(data.AvailableBudget ?? data.availableBudget);
        queryClient.invalidateQueries(['request', requestId]);
      }
    },
  });

  const requestRef = useRef(request);
  useEffect(() => {
    requestRef.current = request;
  }, [request]);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => {
    if (!request || request?.status !== 'WaitingApproval') return;

    const connection = new signalR.HubConnectionBuilder()
      .withUrl('https://localhost:7047/budgetHub')
      .withAutomaticReconnect()
      .build();

    connection.on('BudgetUpdated', (data) => {
      const req = requestRef.current;
      if (!req) return;

      const requestDate = new Date(req.requestDate);
      const reqYear = requestDate.getFullYear();
      const reqMonth = requestDate.getMonth() + 1;

      if (data.year === reqYear && data.month === reqMonth) {
        setAvailableBudgetBeforeApproval(data.remainingBudget);
        setResult(prev => prev ? { ...prev, availableBudget: data.remainingBudget } : prev);
      }
    });

    connection.start().catch(err => console.error('SignalR error:', err));

    return () => connection.stop();
  }, [request?.status]);

  const approveMutation = useMutation({
    mutationFn: (isApproved) => {
      const requestDate = new Date(request.requestDate);
      return approveRequest(requestId, {
        isApproved,
        processedBy: 'פקיד',
        processingYear: requestDate.getFullYear(),
        processingMonth: requestDate.getMonth() + 1,
      }).then(res => res.data);
    },
    onSuccess: (data) => {
      setResult(data);
      queryClient.invalidateQueries(['request', requestId]);
      queryClient.invalidateQueries(['pendingRequests']);
      queryClient.invalidateQueries(['budget']);
    },
  });

  if (isLoading) return <div className="loader">טוען...</div>;
  if (isError) return <div className="error">שגיאה בטעינת הבקשה</div>;
  if (!request) return null;

  const canProcess = request.status === 'WaitingCalculation';
  const canApprove = request.status === 'WaitingApproval';
  const isDone = ['Approved', 'Rejected', 'Paid'].includes(request.status);
  const processing = processMutation.isPending || approveMutation.isPending;

  return (
    <div className="details" dir="rtl">
      <div className="btn-back-wrapper">
        <button
          className="btn-back"
          onClick={onBack}
          disabled={canApprove}
        >
          → חזרה לרשימה
        </button>
        {canApprove && (
          <span className="back-tooltip">יש לאשר או לדחות לפני היציאה</span>
        )}
      </div>

      <div className="details-header">
        <h1>בקשה #{request.requestId}</h1>
        <StatusBadge status={request.status} />
      </div>

      {/* פרטי אזרח */}
      <div className="card">
        <h2>פרטי אזרח</h2>
        <div className="info-grid">
          <div className="info-item">
            <span className="label">שם מלא</span>
            <span className="value">{request.citizenFullName}</span>
          </div>
          <div className="info-item">
            <span className="label">שנת מס</span>
            <span className="value">{request.taxYear}</span>
          </div>
          <div className="info-item">
            <span className="label">תאריך בקשה</span>
            <span className="value">
              {new Date(request.requestDate).toLocaleDateString('he-IL')}
            </span>
          </div>
        </div>
      </div>

      {/* פרטי החזר */}
      <div className="card">
        <h2>פרטי החזר</h2>
        <div className="info-grid">
          {request.calculatedAmount != null && (
            <div className="info-item">
              <span className="label">סכום מחושב</span>
              <span className="value amount">
                ₪{request.calculatedAmount?.toLocaleString()}
              </span>
            </div>
          )}
          {isDone && (
            <div className="info-item">
              <span className="label">סכום מאושר</span>
              <span className="value amount approved">
                ₪{request.approvedAmount?.toLocaleString()}
              </span>
            </div>
          )}
          {request.processedBy && (
            <div className="info-item">
              <span className="label">טופל על ידי</span>
              <span className="value">{request.processedBy}</span>
            </div>
          )}
        </div>
      </div>

      {/* בקשות עבר */}
      {history.length > 0 && (
        <div className="card">
          <h2>בקשות עבר</h2>
          <table className="requests-table">
            <thead>
              <tr>
                <th>שנת מס</th>
                <th>תאריך בקשה</th>
                <th>סטטוס</th>
                <th>סכום מאושר</th>
              </tr>
            </thead>
            <tbody>
              {history.map(req => (
                <tr key={req.requestId}>
                  <td>{req.taxYear}</td>
                  <td>{new Date(req.requestDate).toLocaleDateString('he-IL')}</td>
                  <td><StatusBadge status={req.status} /></td>
                  <td>{req.approvedAmount > 0 ? `₪${req.approvedAmount.toLocaleString()}` : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* הכנסות לפי שנים */}
      {incomes.length > 0 && (
        <div className="card">
          <h2>הכנסות לפי שנים</h2>
          {incomes.map(year => (
            <div key={year.taxYear} className="income-year">
              <div className="income-year-header">
                <span className="income-year-title">שנת {year.taxYear}</span>
                <span className="income-year-stats">
                  {year.monthsCount} חודשים | ממוצע: ₪{Math.round(year.avgIncome).toLocaleString()} | סה"כ: ₪{Math.round(year.totalIncome).toLocaleString()}
                </span>
              </div>
              <div className="income-months">
                {year.months.map(m => (
                  <div key={m.month} className="income-month">
                    <span className="month-name">חודש {m.month}</span>
                    <span className="month-amount">₪{m.incomeAmount.toLocaleString()}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* תקציב זמין לפני אישור */}
      {canApprove && (budgetData !== undefined && budgetData !== null || availableBudgetBeforeApproval !== null) && !result && (
        <div className="result-banner waiting_approval">
          <div className="banner-main">
            <strong>ממתין להחלטת פקיד</strong>
          </div>
          <div className="budget-info">
            <span className="budget-label">תקציב זמין:</span>
            <span className="budget-amount">₪{(budgetData ?? availableBudgetBeforeApproval)?.toLocaleString()}</span>
          </div>
        </div>
      )}

      {/* תוצאת פעולה */}
      {result && (
        <div className={`result-banner ${result.Result?.toLowerCase() ?? result.result?.toLowerCase()}`}>
          <div className="banner-main">
            <strong>{result.Message ?? result.message}</strong>
          </div>
          {(result.availableBudget > 0 || result.AvailableBudget > 0) && !result.RemainingBudget && (
            <div className="budget-info">
              <span className="budget-label">תקציב זמין:</span>
              <span className="budget-amount">
                ₪{(result.availableBudget ?? result.AvailableBudget)?.toLocaleString()}
              </span>
            </div>
          )}
          {result.RemainingBudget > 0 && (
            <div className="budget-info">
              <span className="budget-label">תקציב זמין לאחר עדכון:</span>
              <span className="budget-amount">₪{result.RemainingBudget?.toLocaleString()}</span>
            </div>
          )}
        </div>
      )}

      {/* כפתורי פעולה */}
      <div className="actions">
        {canProcess && (
          <button
            className="btn-primary"
            onClick={() => processMutation.mutate()}
            disabled={processing}
          >
            {processing ? 'מחשב...' : 'חשב זכאות'}
          </button>
        )}

        {canApprove && result?.result !== 'ERROR' && result?.Result !== 'ERROR' && (
          <>
            <button
              className="btn-approve"
              onClick={() => approveMutation.mutate(true)}
              disabled={processing}
            >
              {processing ? '...' : 'אשר בקשה'}
            </button>
            <button
              className="btn-reject"
              onClick={() => approveMutation.mutate(false)}
              disabled={processing}
            >
              דחה בקשה
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default RequestDetails;