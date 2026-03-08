import './StatusBadge.css';

const STATUS_CONFIG = {
  WaitingCalculation: { label: 'ממתין לחישוב', color: 'waiting' },
  WaitingApproval:    { label: 'ממתין לאישור', color: 'pending' },
  Approved:           { label: 'אושר',          color: 'approved' },
  Rejected:           { label: 'נדחה',           color: 'rejected' },
  Paid:               { label: 'שולם',           color: 'paid' },
};

const StatusBadge = ({ status }) => {
  const config = STATUS_CONFIG[status] ?? { label: status, color: 'default' };
  return <span className={`status-badge ${config.color}`}>{config.label}</span>;
};

export default StatusBadge;