# Cash Overflow

**Cash Overflow** is an AI-powered enterprise financial management and cash-flow liquidity forecasting platform. Built using **Flutter Web**, it provides corporate decision-makers with interactive real-time financial dashboards, automated risk prediction via AI, and a seamless subscription onboarding flow.

---

## Key Features

### 1. Interactive Financial Analytics Dashboard
- **Liquidity & Cash Flow Analytics**: Real-time visual metrics, income/expense distribution, and balance trends rendered.
- **Corporate Risk Indicator**: Predictive liquidity assessment to help finance teams mitigate risk early.
- **REST API Integration**: Synchronized with secure backend microservices for enterprise financial data processing.

### 2. Integrated AI Chatbot
- **Financial Assistant**: Context-aware AI chatbot to analyze corporate cash flow trends, generate balance reports, and answer complex financial queries in real-time.

### 3. Admin Dashboard & Demo Request Approval
- **Demo Request Management**: Dedicated administrative view (`DemoRequestsManagementScreen`) for reviewing and approving incoming corporate demo requests.
- **Automated Onboarding Invitations**: Upon admin approval, an automated invite link with a unique security token is generated and sent directly to the requester's email.

### 4. End-to-End Onboarding & Subscription Flow
- **Stripe Test Payment Gateway**: Fully integrated checkout pipeline running in Stripe's test environment.

---

## Testing Credentials & Demo Instructions

If you are evaluating or testing the application, you can use the accounts below or perform a full end-to-end onboarding test:

### Test Accounts

| Role | Email | Password | Access Level |
| :--- | :--- | :--- | :--- |
| **Admin** | `cashoverflow0@gmail.com` | `Admin@123` | Demo Requests Management & Admin Controls |
| **Regular User** | `ahmed@nileconstruction.eg` | `DemoPass123!` | Full Financial Dashboard & AI Chatbot |

---

### Testing the Full End-to-End Onboarding Flow

To test the complete user experience from demo request to paid account setup:

1. **Submit Demo Request**: Go to the landing page and submit a new **Demo Request** with your email.
2. **Admin Approval**: 
   - Log in with the **Admin Account** (`cashoverflow0@gmail.com`).
   - Navigate to the Admin Dashboard to review and **Approve** your submitted request.
3. **Email Invitation**: Check your inbox for the automated invitation link containing the token.
4. **Stripe Test Payment**: Follow the invitation link to proceed to the checkout screen. Use the following Stripe test card:
   - **Card Number**: `4242 4242 4242 4242`
   - **Expiry Date**: *Any future date (e.g., 12/28)*
   - **CVC**: *Any 3 digits (e.g., 123)*
5. **Account Activation**: After payment success, complete your password setup (`/set-password`) to gain instant access to your company dashboard.

---
