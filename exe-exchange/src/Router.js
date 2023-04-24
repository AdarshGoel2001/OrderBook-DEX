import React from 'react'
import {createBrowserRouter} from 'react-router-dom'
import App from './App';
import Trade from './components/Trade';
import Reg from './components/Reg';

export const router = createBrowserRouter([
    {
      path: "/",
      element: <App />,
    },
    {
        path: "/trade",
        element: <Trade />,
    },
    {
        path: "/register",
        element: <Reg/>
    }
  ]);
