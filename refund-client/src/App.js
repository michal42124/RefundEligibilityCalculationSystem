import { useState } from 'react';
import ClerkDashboard from './components/clerk/ClerkDashboard';
import RequestDetails from './components/clerk/RequestDetails';
import CitizenView from './components/citizen/CitizenView';
import './App.css';

const VIEWS = {
  CLERK_DASHBOARD: 'clerk_dashboard',
  REQUEST_DETAILS: 'request_details',
  CITIZEN:         'citizen',
};

const App = () => {
  const [view, setView]           = useState(VIEWS.CLERK_DASHBOARD);
  const [selectedRequestId, setSelectedRequestId] = useState(null);

  const handleSelectRequest = (requestId) => {
    setSelectedRequestId(requestId);
    setView(VIEWS.REQUEST_DETAILS);
  };

  const handleBack = () => {
    setSelectedRequestId(null);
    setView(VIEWS.CLERK_DASHBOARD);
  };

  return (
    <div className="app">
      {/* Navbar */}
      <nav className="navbar">
        <span className="navbar-brand">מערכת החזרי מס</span>
        <div className="navbar-links">
          <button
            className={view === VIEWS.CLERK_DASHBOARD || view === VIEWS.REQUEST_DETAILS ? 'active' : ''}
            onClick={() => setView(VIEWS.CLERK_DASHBOARD)}
          >
            ממשק פקיד
          </button>
          <button
            className={view === VIEWS.CITIZEN ? 'active' : ''}
            onClick={() => setView(VIEWS.CITIZEN)}
          >
            ממשק אזרח
          </button>
        </div>
      </nav>

      {/* תוכן */}
      <main className="main-content">
        {view === VIEWS.CLERK_DASHBOARD && (
          <ClerkDashboard onSelectRequest={handleSelectRequest} />
        )}
        {view === VIEWS.REQUEST_DETAILS && (
          <RequestDetails requestId={selectedRequestId} onBack={handleBack} />
        )}
        {view === VIEWS.CITIZEN && (
          <CitizenView />
        )}
      </main>
    </div>
  );
};

export default App;