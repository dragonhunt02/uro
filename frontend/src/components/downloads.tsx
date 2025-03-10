// import React, { ComponentProps } from 'react';
import type { ComponentProps, FC } from "react";

// Define the type for the table data
interface Data {
  id: number;
  name: string;
}

// Define the props for the table component using ComponentProps
const TableComponent: React.FC<ComponentProps<'table'> & { data: Data[] }> = ({ data, ...props }) => {
  return (
    <table {...props} className="min-w-full divide-y divide-gray-200">
      <thead className="bg-gray-50">
        <tr>
          <th>ID</th>
          <th>Name</th>
        </tr>
      </thead>
      <tbody className="bg-white divide-y divide-gray-200">
        {data.map((item) => (
          <tr key={item.id}>
            <td>{item.id}</td>
            <td>{item.name}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default TableComponent;
