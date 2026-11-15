# Phase 1: Problem Understanding

## 1. Introduction

The OLX Used Goods Marketplace faces performance issues in advertisement searching, management, communication, moderation, and business reporting. This phase identifies the affected stakeholders and classifies the problems according to their performance requirements.

## 2. Problem Identification and Classification

| ID | Business Requirement | Stakeholder | Classification |
| -- | -- | -- | -- |
| P1 | Enable buyers to search and browse ads quickly using price, car details, and location filters. | Buyers | Customer-facing / Real-time |
| P2 | Allow sellers to access My Ads, post advertisements, and mark ads as sold quickly. | Sellers | Customer-facing / Real-time |
| P3 | Provide fast chat inbox access, unread message counts, and message sending. | Buyers and Sellers | Customer-facing / Real-time |
| P4 | Quickly identify reported ads, spam activity, and duplicate listings. | Moderation Team | Customer-facing / Real-time |
| P5 | Generate accurate reports of purchased boost packages. | Monetisation | Reporting / Analytics |
| P6 | Generate insights on average prices, selling time, offer acceptance, and seller responsiveness. | Category Managers | Reporting / Analytics |
| P7 | Efficiently execute growth reports, reminders, and nightly jobs as the platform grows by 20 times. | Growth / Platform | Reporting / Analytics |

## 3. Assumptions

1. Customer-facing operations require quick responses to maintain a good user experience.
2. Reporting and analytics queries may process large datasets and can run in the background.
3. Moderation activities are time-sensitive and require timely identification of suspicious ads.
4. Scheduled jobs and reminders do not always require immediate user interaction.
5. The database should maintain good performance even with 20 times the current advertisement volume.

## 4. Conclusion

The project requires a database that supports fast customer-facing operations and efficient reporting and analytics. These requirements will guide schema design, query benchmarking, optimization, and scalability testing.