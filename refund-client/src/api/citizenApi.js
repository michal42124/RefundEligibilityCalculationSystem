import api from './axiosInstance';

export const getCitizenByIdNumber = (idNumber) => api.get(`/citizen/${idNumber}`);
export const getCitizenHistory = (citizenId) => api.get(`/citizen/${citizenId}/history`);
export const getCitizenIncomes    = (citizenId) => api.get(`/citizen/${citizenId}/incomes`);