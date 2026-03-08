import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { getCitizenByIdNumber, getCitizenHistory } from '../../api';
import StatusBadge from '../shared/StatusBadge';
import './CitizenView.css';

const CitizenView = () => {
  const [idNumber, setIdNumber] = useState('');
  const [searchId, setSearchId] = useState('');

  const { data: citizen, isLoading: citizenLoading, isError: citizenError } = useQuery({
    queryKey: ['citizen', searchId],
    queryFn: () => getCitizenByIdNumber(searchId).then(res => res.data),
    enabled: !!searchId,
  });

  const { data: history = [] } = useQuery({
    queryKey: ['citizenHistory', citizen?.citizenId],
    queryFn: () => getCitizenHistory(citizen.citizenId).then(res => res.data),
    enabled: !!citizen?.citizenId,
  });

  const handleSearch = () => {
    if (idNumber.trim()) setSearchId(idNumber.trim());
  };

  const latestRequest = history[0];

  return (
    <div className="citizen-view" dir="rtl">
      <div className="citizen-header">
        <h1>מסך אזרח</h1>
        <p>הזן תעודת זהות לצפייה בפרטי הבקשות</p>
      </div>

      {/* חיפוש */}
      <div className="search-box">
        <input
          type="text"
          placeholder="הזן תעודת זהות..."
          value={idNumber}
          onChange={e => setIdNumber(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && handleSearch()}
        />
        <button onClick={handleSearch} disabled={citizenLoading}>
          {citizenLoading ? 'מחפש...' : 'חפש'}
        </button>
      </div>

      {citizenError && <div className="error">אזרח לא נמצא</div>}

      {citizen && (
        <>
          {/* פרטי אזרח */}
          <div className="card">
            <h2>פרטי אזרח</h2>
            <div className="info-grid">
              <div className="info-item">
                <span className="label">שם מלא</span>
                <span className="value">{citizen.fullName}</span>
              </div>
              <div className="info-item">
                <span className="label">תעודת זהות</span>
                <span className="value">{citizen.idNumber}</span>
              </div>
            </div>
          </div>

          {/* בקשה אחרונה */}
          {latestRequest && (
            <div className="card">
              <h2>בקשה אחרונה</h2>
              <div className="info-grid">
                <div className="info-item">
                  <span className="label">שנת מס</span>
                  <span className="value">{latestRequest.taxYear}</span>
                </div>
                <div className="info-item">
                  <span className="label">סטטוס</span>
                  <StatusBadge status={latestRequest.status} />
                </div>
                <div className="info-item">
                  <span className="label">סכום מחושב</span>
                  <span className="value amount">
                    {latestRequest.calculatedAmount != null
                      ? `₪${latestRequest.calculatedAmount.toLocaleString()}`
                      : '—'}
                  </span>
                </div>
                <div className="info-item">
                  <span className="label">סכום מאושר</span>
                  <span className="value amount approved">
                    {latestRequest.approvedAmount > 0
                      ? `₪${latestRequest.approvedAmount.toLocaleString()}`
                      : '—'}
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* היסטוריה */}
          <div className="card">
            <h2>היסטוריית בקשות</h2>
            {history.length === 0 ? (
              <p className="empty">אין היסטוריה</p>
            ) : (
              <table className="history-table">
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
                      <td>
                        {req.approvedAmount > 0
                          ? `₪${req.approvedAmount.toLocaleString()}`
                          : '—'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}
    </div>
  );
};

export default CitizenView;