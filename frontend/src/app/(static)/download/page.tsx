"use client";

import React, { useEffect, useState } from 'react';
import { InlineLink } from '~/components/link';
import { urls } from '~/environment';
import { Section, SectionTitle } from '~/app/(static)/section';
import { Footer } from '~/app/footer';
import { api } from '~/api';
import { useListSharedFiles } from '~/hooks/downloads';
import TableComponent from '~/components/TableComponent';

// Define the type for the table data
interface Data {
  id: number;
  name: string;
}

// Define sample data for the table
const sampleData: Data[] = [
  { id: 1, name: 'John Doe' },
  { id: 2, name: 'Jane Smith'}
];

export default function AboutPage() {
//export const AboutPage: React.FC = () => {
  //const [data, setData] = useState<Data[]>([]);
  {
  const sharedFiles = useListSharedFiles();
    
  const data: Data[] = sharedFiles.data ?? [];
  //const data: Data[] = sharedFiles ? (sharedFiles as Data[]) : [];

//  const sharedFiles: Data[] = useListSharedFiles();

/*
  useEffect(() => {
    fetch('https://api.example.com/data')
      .then(response => response.json())
      .then(data => setData(data))
      .catch(error => console.error('Error fetching data:', error));
  }, []);
*/
  return (
    <main className="mx-auto flex size-full max-w-screen-lg grow flex-col pt-8 lg:pt-16">
      <div className="mx-auto flex w-full max-w-screen-md flex-col gap-4 px-4 text-lg">
        <Section>
          <SectionTitle>Download</SectionTitle>
          <p>
            V-Sekai is still currently in closed testing. Please check back here
            later for more information.
          </p>
        </Section>
        <Section>
          <SectionTitle>Sign up to receive updates</SectionTitle>
          <p>
            At the moment, we have functional prototypes, but are still deep in
            development. We have slowly been offering download keys to a small
            group of private volunteering testers. We want to ensure that our
            formal release is as polished as it can be.
          </p>
          <p>
            <InlineLink href="/sign-up">Register now</InlineLink> to reserve
            your name and to receive updates on future beta participation. You
            can also follow us on{" "}
            <InlineLink href={urls.twitter}>Twitter</InlineLink> for updates on
            the project.
          </p>
        </Section>
        <Section>
          <SectionTitle>Sample Data Table</SectionTitle>
          <TableComponent data={sharedFiles} />
        </Section>
      </div>
      <Footer />
    </main>
  );
};
};
//export default AboutPage;
