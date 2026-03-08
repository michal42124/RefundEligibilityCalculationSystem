import api from './axiosInstance';

export const getPendingRequests      = ()           => api.get('/refund/pending');
export const getRequestById          = (id)         => api.get(`/refund/${id}`);
export const processRequest          = (id)         => api.post(`/refund/${id}/process`);
export const approveRequest          = (id, data)   => api.post(`/refund/${id}/approve`, data);
export const getBudget               = (year, month)=> api.get(`/refund/budget/${year}/${month}`);
export const exportApprovedPdf = (year) => api.get(`/refund/export/pdf/${year}`, { responseType: 'blob' });