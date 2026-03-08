import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { getPendingRequests, exportApprovedPdf } from '../../api';
import StatusBadge from '../shared/StatusBadge';
import './ClerkDashboard.css';
import { Download } from 'lucide-react';

const ClerkDashboard = ({ onSelectRequest }) => {
  const [exportYear, setExportYear] = useState('');
  const [exporting, setExporting] = useState(false);

  const { data: requests = [], isLoading, isError } = useQuery({
    queryKey: ['pendingRequests'],
    queryFn: () => getPendingRequests().then(res => res.data),
  });

  const handleExport = async () => {
    setExporting(true);
    try {
      const response = await exportApprovedPdf(exportYear);
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `approved_requests_${exportYear}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
    } catch {
      alert('שגיאה בייצוא הקובץ');
    } finally {
      setExporting(false);
    }
  };

  if (isLoading) return <div className="loader">טוען...</div>;
  if (isError) return <div className="error">שגיאה בטעינת הבקשות</div>;

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>בקשות ממתינות לטיפול</h1>
        <span className="badge-count">{requests.length} בקשות</span>
      </div>

      {/* ייצוא בקשות מאושרות לפי שנת מס */}
      <div className="export-bar">
        <div className="export-bar-text">
          <span className="export-title">ייצוא דוח בקשות מאושרות</span>
          <span className="export-subtitle">בחר שנת מס והורד דוח PDF</span>
        </div>
        <div className="export-bar-actions">
          <input
            type="number"
            value={exportYear}
            onChange={e => setExportYear(e.target.value)}
            min="2020"
            max="2030"
            placeholder="הזן שנה"
          />
          <button onClick={handleExport} disabled={exporting} className="btn-export" title="הורד PDF">
            {exporting ? '⏳' : <Download size={18} />}
          </button>
        </div>
      </div>

      {requests.length === 0 ? (
        <div className="empty">אין בקשות ממתינות</div>
      ) : (
        <table className="requests-table">
          <thead>
            <tr>
              <th>מספר בקשה</th>
              <th>שם אזרח</th>
              <th>שנת מס</th>
              <th>תאריך בקשה</th>
              <th>סטטוס</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {requests.map(req => (
              <tr key={req.requestId}>
                <td>#{req.requestId}</td>
                <td>{req.citizenFullName}</td>
                <td>{req.taxYear}</td>
                <td>{new Date(req.requestDate).toLocaleDateString('he-IL')}</td>
                <td><StatusBadge status={req.status} /></td>
                <td>
                  <button
                    className="btn-view"
                    onClick={() => onSelectRequest(req.requestId)}
                  >
                    פתח בקשה
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default ClerkDashboard;