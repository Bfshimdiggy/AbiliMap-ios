import { chromium } from 'playwright';

(async () => {
  // Launch browser
  const browser = await chromium.launch({ headless: false }); // Set headless: true if you don't need to see the browser
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to the ADA submission form
  await page.goto('https://civilrights.justice.gov/report/?utm_campaign=499a0d26-884a-47aa-9afc-70094d92e6f5');

  // Fill in the required fields (example values provided)
  await page.selectOption('#Section3Form #subject', 'Americans with Disabilities Act');
  await page.fill('#Section3Form #firstName', 'John');
  await page.fill('#Section3Form #lastName', 'Doe');
  await page.fill('#Section3Form #address1', '123 Main St');
  await page.fill('#Section3Form #city', 'Anytown');
  await page.selectOption('#Section3Form #state', 'NY');
  await page.fill('#Section3Form #zip', '12345');
  await page.fill('#Section3Form #phone', '1234567890');
  await page.fill('#Section3Form #email', 'john.doe@example.com');

  // Fill in the description of the issue
  await page.fill('#Section3Form #incidentDescription', 'Description of the ADA issue goes here.');

  // Submit the form
  await page.click('#Section3Form button[type="submit"]');

  // Wait for a confirmation message or redirection
  await page.waitForSelector('.submission-confirmation', { timeout: 10000 }); // Adjust selector and timeout as needed

  console.log('Form submitted successfully.');

  // Close browser
  await browser.close();
})();
