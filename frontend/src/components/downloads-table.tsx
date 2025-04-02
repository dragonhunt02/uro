import React from "react";
import type { ComponentProps } from "react";

// Define the type for the table data
export interface SharedFile {
  id: string;
  name: string;
  tags: string[];
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

function getPlatform(tags: string[]): string {
  const platforms = ["Windows", "Linux", "Android","QuestAndroid","Web","macOS","iOS"];
  for (const platform of platforms) {
    if (tags.includes(platform)) {
      return platform;
    }
  }
  return "";
}

// Define the table component with descending sort for versions and separators for cells
export const DownloadsTable: React.FC<ComponentProps<"div"> & { data: SharedFile[] }> = ({ data, ...props }) => {
  const groupedData = groupByVersion(data);

  // Sort the grouped versions in descending alphanumerical order
  const sortedEntries = Object.entries(groupedData).sort((a, b) =>
    b[0].localeCompare(a[0], undefined, { numeric: true, sensitivity: "base" })
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
                <th className="px-4 py-2 border-r border-gray-200">ID</th>
                <th className="px-4 py-2 border-r border-gray-200">Name</th>
                <th className="px-4 py-2">Checksum</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {files.map((file) => (
                <tr key={file.id}>
                  <td className="px-4 py-2 border-r border-gray-200">{file.name}</td>
                  <td className="px-4 py-2 border-r border-gray-200">{getPlatform(file.tags)}</td>
                  <td className="px-4 py-2">{file.checksum}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  );
};
