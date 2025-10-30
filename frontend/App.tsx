import React from 'react';

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4">
          <h1 className="text-3xl font-bold text-gray-900">
            🦷 DenteScope AI
          </h1>
          <p className="text-gray-600">
            Powered by NVIDIA Jetson Thor
          </p>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto py-6 px-4">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">
            Upload Dental X-Ray
          </h2>
          <p className="text-gray-600">
            Drag and drop your panoramic X-ray here
          </p>
        </div>
      </main>
    </div>
  );
}

export default App;
