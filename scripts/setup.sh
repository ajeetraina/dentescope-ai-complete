#!/bin/bash

echo "Setting up DenteScope AI..."

# Install Python dependencies
cd backend
pip install -r requirements.txt
cd ..

# Install frontend dependencies
cd frontend
npm install
cd ..

echo "Setup complete!"
