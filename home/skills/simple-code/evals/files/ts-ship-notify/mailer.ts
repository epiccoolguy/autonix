export async function sendEmail(to: string, subject: string, body: string): Promise<void> {
  const res = await fetch("https://mail.internal/send", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ to, subject, body }),
  });
  if (!res.ok) {
    throw new Error(`send email to ${to}: HTTP ${res.status}`);
  }
}
