# AWS CloudFront + S3 + Z.com Infrastructure Setup

This document outlines the architecture for **centralnex.com**, utilizing AWS S3 for storage and CloudFront for high-availability HTTPS delivery.

---

## 🏗 Architecture Overview
- **Primary Site:** Hosted on S3 (`www.centralnex.com`) via CloudFront.
- **Root Redirect:** Handled by a secondary S3 bucket (`centralnex.com`) redirecting to the `www` subdomain.
- **Security:** SSL/TLS handled by AWS Certificate Manager (ACM).
- **Access Control:** Origin Access Control (OAC) restricts S3 access to CloudFront only.

---

## 1. Primary Storage: S3 (`www.centralnex.com`)
* **Bucket Name:** `www.centralnex.com`
* **Region:** `ap-southeast-1` (Singapore)
* **Block Public Access:** **ON** (Private bucket).
* **Static Website Hosting:** **Enabled** (Index document: `index.html`).
* **Bucket Policy:** Configured to allow `s3:GetObject` from the CloudFront Service Principal.
    * *Note: Ensure the Resource ARN ends with `/*` to grant access to all files.*

## 2. Content Delivery: CloudFront
* **Origin Domain:** `www.centralnex.com.s3.ap-southeast-1.amazonaws.com`
* **Origin Access:** **OAC** (Origin Access Control).
* **Alternate Domain Names (CNAMEs):** `www.centralnex.com`
* **SSL Certificate:** Custom ACM Certificate (Must be in `us-east-1`).
* **Default Root Object:** `index.html`
* **CRITICAL FIX:** **Origin Path** must be left **empty** (blank). Setting this to `/` will result in a `403 Access Denied` error.

## 3. Root Domain Redirect: S3 (`centralnex.com`)
Since z.com does not support CNAME records for the root domain (`@`), we use a redirect bucket:
* **Bucket Name:** `centralnex.com`
* **Static Website Hosting:** **Redirect requests to an object**.
* **Target Hostname:** `www.centralnex.com`
* **Protocol:** `https`
* **Permissions:** **Block Public Access must be OFF** (This is required specifically for S3's website redirect endpoint to be reachable).

## 4. DNS Records: Z.com
| Type | Name | Value | Purpose |
| :--- | :--- | :--- | :--- |
| **CNAME** | `www` | `[Your-ID].cloudfront.net` | Points sub-domain to CDN |
| **A** | `@` | `[S3-Redirect-IP]` | Redirects root traffic to `www` |
| **CNAME** | `_...` | `_...acm-validations.aws` | AWS SSL Certificate validation |

---

## 🚀 Maintenance & Updates
### Uploading New Content
1.  Upload files to the `www.centralnex.com` S3 bucket.
2.  If changes do not reflect immediately, create a **CloudFront Invalidation** for the path `/*`.

### Troubleshooting
- **403 Forbidden:** Check that the CloudFront **Origin Path** is empty.
- **Access Denied:** Verify the S3 Bucket Policy includes the `/*` suffix on the Resource line.
- **Redirect Issues:** Ensure the `centralnex.com` bucket is set to "Static Website Hosting" mode and is not empty of redirect rules.
