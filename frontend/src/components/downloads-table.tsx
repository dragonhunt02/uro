import React from "react";
import type { ComponentProps } from "react";

// Define the type for the table data
export interface SharedFile {
  id: string;
  name: string;
  checksum: string;
  version: string;
}

// Group data by version
const groupByVersion = (data: SharedFile[]): Record<string, SharedFile[]> => {
  return data.reduce((acc, item) => {
    (acc[item.version] = acc[item.version] || []).push(item);
    return acc;
  }, {} as Record<string, SharedFile[]>);
};

// Define the table component
export const DownloadsTable: React.FC<ComponentProps<"div"> & { data: SharedFile[] }> = ({ data, ...props }) => {
  const groupedData = groupByVersion(data);

  // Sort the grouped versions alphanumerically (natural sort)
  const sortedEntries = Object.entries(groupedData).sort((a, b) =>
    a[0].localeCompare(b[0], undefined, { numeric: true, sensitivity: 'base' })
  );

  return (
    <div {...props} className="divide-y divide-gray-200">
      {sortedEntries.map(([version, files]) => (
        <div key={version}>
          {/* Version header */}
          <h3 className="bg-gray-100 px-4 py-2 font-semibold">Version: {version}</h3>
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Checksum</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {files.map((file) => (
                <tr key={file.id}>
                  <td>{file.id}</td>
                  <td>{file.name}</td>
                  <td>{file.checksum}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  );
};
