import 'dart:math';
import '../../models/sms_detection.dart';
import '../../models/call_detection.dart';
import '../../models/threat_stats.dart';
import '../../../domain/entities/threat_classification.dart';

class MockApiService {
  final Random _random = Random();

  // Simulate network delay
  Future<void> _delay() =>
      Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

  // Generate realistic mock SMS detections
  Future<List<SmsDetection>> getMockSmsDetections() async {
    await _delay();
    return _mockSmsData;
  }

  Future<List<CallDetection>> getMockCallDetections() async {
    await _delay();
    return _mockCallData;
  }

  Future<ThreatStats> getMockStats() async {
    await _delay();
    return ThreatStats(
      totalThreatsBlocked: 47,
      smsScamsBlocked: 32,
      vishingAttemptsBlocked: 15,
      todayThreats: 3,
      weekThreats: 12,
      monthThreats: 47,
      threatsByDay: {
        'Mon': 5,
        'Tue': 8,
        'Wed': 6,
        'Thu': 9,
        'Fri': 7,
        'Sat': 4,
        'Sun': 8,
      },
      lastUpdated: DateTime.now(),
    );
  }

  // Simulate AI analysis
  Future<SmsDetection> analyzeSmsMessage(String sender, String message) async {
    await _delay();

    final lowerMessage = message.toLowerCase();
    final hasUrgency =
        lowerMessage.contains('urgent') ||
        lowerMessage.contains('immediately') ||
        lowerMessage.contains('asap') ||
        lowerMessage.contains('act now');
    final hasLink =
        lowerMessage.contains('http') ||
        lowerMessage.contains('bit.ly') ||
        lowerMessage.contains('tinyurl') ||
        lowerMessage.contains('.com');
    final hasFinancial =
        lowerMessage.contains('account') ||
        lowerMessage.contains('payment') ||
        lowerMessage.contains('bank') ||
        lowerMessage.contains('card') ||
        lowerMessage.contains('otp');
    final hasMoneyRequest =
        lowerMessage.contains('send') ||
        lowerMessage.contains('transfer') ||
        lowerMessage.contains('gcash') ||
        lowerMessage.contains('paymaya');

    ThreatClassification classification;
    double confidence;
    List<String> reasons = [];

    if ((hasUrgency && hasLink && hasFinancial) ||
        (hasMoneyRequest && hasFinancial)) {
      classification = ThreatClassification.confirmedScam;
      confidence = 0.92 + _random.nextDouble() * 0.07;
      reasons = [
        if (hasUrgency) 'Urgency keywords detected',
        if (hasLink) 'Suspicious shortened URL detected',
        if (hasFinancial) 'Financial terms present',
        if (hasMoneyRequest) 'Requests money transfer',
        'Pattern matches known scam templates',
      ];
    } else if (hasLink || hasUrgency || hasMoneyRequest) {
      classification = ThreatClassification.suspicious;
      confidence = 0.65 + _random.nextDouble() * 0.15;
      reasons = [
        if (hasUrgency) 'Contains urgency language',
        if (hasLink) 'Contains external link',
        if (hasMoneyRequest) 'Mentions payment method',
        'Requires manual verification',
      ];
    } else {
      classification = ThreatClassification.legitimate;
      confidence = 0.85 + _random.nextDouble() * 0.13;
      reasons = ['No threat indicators found', 'Message appears genuine'];
    }

    return SmsDetection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      messagePreview: message.length > 100
          ? '${message.substring(0, 100)}...'
          : message,
      fullMessage: message,
      classification: classification,
      confidence: confidence,
      detectionReasons: reasons,
      timestamp: DateTime.now(),
    );
  }

  // Mock SMS data with Filipino context
  static final List<SmsDetection> _mockSmsData = [
    // CONFIRMED SCAMS
    SmsDetection(
      id: '1',
      sender: '+639171234567',
      messagePreview:
          'URGENT: Your BDO account has been locked. Click here to verify: bit.ly/3xK9mL',
      fullMessage:
          'URGENT: Your BDO account has been locked due to suspicious activity. Click here to verify within 24 hours: bit.ly/3xK9mL or your account will be permanently closed.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.96,
      detectionReasons: [
        'Contains urgency keywords',
        'Suspicious shortened URL detected',
        'Impersonates legitimate bank',
        'Requests immediate action',
        'Threatens account closure',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SmsDetection(
      id: '2',
      sender: '+639281234568',
      messagePreview:
          'Sir/Mam, you have pending delivery from LBC. Please send 2,500 pesos to GCash 09171234567...',
      fullMessage:
          'Sir/Mam, you have pending delivery from LBC that requires customs clearance. Please send 2,500 pesos to GCash 09171234567 for release. Reference: LBC2024-45678',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.94,
      detectionReasons: [
        'Requests money transfer',
        'Impersonates courier service',
        'Contains payment instructions',
        'Unusual customs fee request',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    SmsDetection(
      id: '3',
      sender: 'BPI-Alert',
      messagePreview:
          'ALERT: Unauthorized transaction detected. Verify your account now: bpi-secure.com/verify',
      fullMessage:
          'ALERT: Unauthorized transaction of PHP 15,000 detected on your BPI account. Verify your account now: bpi-secure.com/verify?id=8372649. Failure to verify will result in account suspension.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.98,
      detectionReasons: [
        'Spoofed sender name',
        'Fake security alert',
        'Suspicious domain (not official BPI)',
        'Creates false urgency',
        'Threatens account suspension',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    SmsDetection(
      id: '4',
      sender: '+639991234569',
      messagePreview:
          'Congratulations! You won 500,000 pesos in SM Mall raffle. Claim prize by sending processing fee...',
      fullMessage:
          'Congratulations! You won 500,000 pesos in SM Mall raffle draw. To claim your prize, send processing fee of 3,000 pesos to this account: BDO 1234567890. Name: Maria Santos. Contact 09991234569 after payment.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.97,
      detectionReasons: [
        'Prize/lottery scam pattern',
        'Requests advance payment',
        'Too good to be true offer',
        'Provides bank account details',
        'Classic advance-fee fraud',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SmsDetection(
      id: '5',
      sender: '+639181234570',
      messagePreview:
          'SSS Advisory: Your account needs update. Visit sss-gov.ph.verify.com and submit requirements...',
      fullMessage:
          'SSS Advisory: Your account needs immediate update to continue receiving benefits. Visit sss-gov.ph.verify.com and submit valid ID, bank details and contact information within 48 hours.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.95,
      detectionReasons: [
        'Impersonates government agency',
        'Fake government website',
        'Requests sensitive information',
        'Domain typosquatting detected',
        'Urgency tactic (48 hours)',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    SmsDetection(
      id: '6',
      sender: 'LAZADA',
      messagePreview:
          'Your Lazada order is on hold. Confirm payment of 8,999 pesos via this link: lazada.co.ph...',
      fullMessage:
          'Your Lazada order #LZ8372648293 is on hold due to payment verification issue. Confirm payment of 8,999 pesos via this link: lazada.co.ph.verify.net/order. Respond within 6 hours or order will be cancelled.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.93,
      detectionReasons: [
        'Fake order notification',
        'Suspicious domain variation',
        'Requests immediate payment',
        'Uses fake order number',
        'Time pressure tactic',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
    ),
    SmsDetection(
      id: '7',
      sender: '+639201234571',
      messagePreview:
          'NBI Clearance ready for pickup. Pay 350 pesos processing fee to GCash 09201234571...',
      fullMessage:
          'Your NBI Clearance is ready for pickup at Manila office. Pay 350 pesos processing fee to GCash 09201234571 (Juan Dela Cruz). Send proof of payment and receive clearance via courier today.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.91,
      detectionReasons: [
        'Fake government service',
        'Requests personal payment',
        'NBI doesn\'t use GCash',
        'Promises instant delivery',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SmsDetection(
      id: '8',
      sender: '+639121234572',
      messagePreview:
          'PLDT Bill Overdue! Pay 2,450 pesos immediately to avoid disconnection. Pay via...',
      fullMessage:
          'PLDT Bill Overdue! Your account 02-1234567 has unpaid balance of 2,450 pesos. Pay immediately to avoid disconnection tomorrow. Pay via GCash to 09121234572 or visit pldt-billing.com.ph',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.94,
      detectionReasons: [
        'Fake billing notice',
        'Threatens service disconnection',
        'Unofficial payment method',
        'Suspicious payment website',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    ),

    // SUSPICIOUS MESSAGES
    SmsDetection(
      id: '9',
      sender: '+639301234573',
      messagePreview:
          'Hello! I have business proposal for you. Earn 50k monthly working from home. Text INTERESTED...',
      fullMessage:
          'Hello! I have business proposal for you. Earn 50,000 monthly working from home. No experience needed. Text INTERESTED to this number or visit workfromhome-ph.com for details.',
      classification: ThreatClassification.suspicious,
      confidence: 0.78,
      detectionReasons: [
        'Unsolicited business offer',
        'Too good to be true income claim',
        'No clear business details',
        'Requires contact response',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SmsDetection(
      id: '10',
      sender: '+639401234574',
      messagePreview:
          'Your parcel from China arrived. Pay customs duty 1,800 pesos. Contact J&T hotline...',
      fullMessage:
          'Your parcel from China arrived at customs. Pay customs duty 1,800 pesos. Contact J&T hotline 09401234574 for payment instructions and delivery schedule.',
      classification: ThreatClassification.suspicious,
      confidence: 0.72,
      detectionReasons: [
        'Unexpected delivery notification',
        'Requests customs payment',
        'Non-official contact number',
        'Should verify with official J&T',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
    ),
    SmsDetection(
      id: '11',
      sender: 'FREEBIES',
      messagePreview:
          'Get FREE Jollibee vouchers! Answer quick survey at jollibee-promo.net. Limited time only!',
      fullMessage:
          'Get FREE Jollibee vouchers worth 500 pesos! Answer our quick survey at jollibee-promo.net. Limited time only! Share to 5 friends to qualify. Promo ends tonight!',
      classification: ThreatClassification.suspicious,
      confidence: 0.75,
      detectionReasons: [
        'Free offer with conditions',
        'Non-official domain',
        'Requires sharing to friends',
        'Artificial urgency (ends tonight)',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    SmsDetection(
      id: '12',
      sender: '+639501234575',
      messagePreview:
          'Loan approved! 50,000 pesos available. Low interest. Complete application at...',
      fullMessage:
          'Congratulations! Your loan of 50,000 pesos is pre-approved. Low interest rate, no collateral needed. Complete application at quickloan-ph.com or call 09501234575.',
      classification: ThreatClassification.suspicious,
      confidence: 0.71,
      detectionReasons: [
        'Unsolicited loan offer',
        'Pre-approved without application',
        'Too easy qualification',
        'Should verify legitimacy',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
    ),
    SmsDetection(
      id: '13',
      sender: '+639601234576',
      messagePreview:
          'Update your PhilHealth account. Visit link: philhealth-update.com/member123',
      fullMessage:
          'PhilHealth Notice: Update your member information before end of month. Visit link: philhealth-update.com/member123 and provide current details to avoid benefit suspension.',
      classification: ThreatClassification.suspicious,
      confidence: 0.76,
      detectionReasons: [
        'Unofficial PhilHealth website',
        'Requests personal information',
        'Domain doesn\'t match official site',
        'Verify with official PhilHealth',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),

    // LEGITIMATE MESSAGES
    SmsDetection(
      id: '14',
      sender: 'BDO',
      messagePreview:
          'Your BDO OTP is 482736. Valid for 5 minutes. Do not share this code.',
      fullMessage:
          'Your BDO Online Banking OTP is 482736. Valid for 5 minutes. Do not share this code with anyone. If you did not request this, contact BDO immediately.',
      classification: ThreatClassification.legitimate,
      confidence: 0.89,
      detectionReasons: [
        'Official bank OTP format',
        'Includes security warning',
        'Standard OTP validity period',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SmsDetection(
      id: '15',
      sender: 'GCASH',
      messagePreview:
          'You received P500.00 from Juan Dela Cruz. Your new balance is P2,450.00',
      fullMessage:
          'You received P500.00 from Juan Dela Cruz (09171234567) on Dec 15, 2024 3:45 PM. Transaction Ref: GC2024121545678. Your new GCash balance is P2,450.00.',
      classification: ThreatClassification.legitimate,
      confidence: 0.92,
      detectionReasons: [
        'Official GCash notification format',
        'Contains valid transaction reference',
        'No suspicious requests',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    SmsDetection(
      id: '16',
      sender: 'SHOPEE',
      messagePreview:
          'Your Shopee order is out for delivery today. Track: shopee.ph/track/SP2024...',
      fullMessage:
          'Your Shopee order #SP202412154567 is out for delivery today. Estimated arrival: 2-5 PM. Track your order: shopee.ph/track/SP2024121545678. Thank you for shopping with Shopee!',
      classification: ThreatClassification.legitimate,
      confidence: 0.91,
      detectionReasons: [
        'Official Shopee domain',
        'Standard order notification',
        'Valid tracking format',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    SmsDetection(
      id: '17',
      sender: 'MERALCO',
      messagePreview:
          'Your Meralco bill for December 2024 is ready. Amount due: 3,450.50. Due date: Dec 28.',
      fullMessage:
          'Your Meralco bill for December 2024 is ready. Amount due: P3,450.50. Due date: December 28, 2024. Pay online at meralco.com.ph or authorized payment centers.',
      classification: ThreatClassification.legitimate,
      confidence: 0.88,
      detectionReasons: [
        'Standard utility bill notification',
        'Official Meralco domain',
        'No urgent payment pressure',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    SmsDetection(
      id: '18',
      sender: 'GRAB',
      messagePreview:
          'Your Grab ride is arriving in 3 minutes. Driver: Mario (GWN-1234) Toyota Vios White',
      fullMessage:
          'Your Grab ride is arriving in 3 minutes. Driver: Mario Santos, 4.9★ rating. Vehicle: GWN-1234, Toyota Vios (White). Contact: 09171234567. Track driver in app.',
      classification: ThreatClassification.legitimate,
      confidence: 0.93,
      detectionReasons: [
        'Active ride notification',
        'Contains booking details',
        'Standard Grab format',
      ],
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    SmsDetection(
      id: '19',
      sender: 'SMART',
      messagePreview:
          'SMART: You have successfully subscribed to GIGA99. Valid until Dec 18. Data balance: 8GB',
      fullMessage:
          'SMART: You have successfully subscribed to GIGA99 (P99 for 8GB + unli calls). Valid until December 18, 2024. Current data balance: 8GB. To check balance, dial *123#',
      classification: ThreatClassification.legitimate,
      confidence: 0.90,
      detectionReasons: [
        'Official telco notification',
        'Standard subscription confirmation',
        'Contains valid promo details',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    SmsDetection(
      id: '20',
      sender: '+639876543210',
      messagePreview: 'Hi! Meeting at 3pm tomorrow at Starbucks BGC. See you!',
      fullMessage:
          'Hi! Just confirming our meeting at 3pm tomorrow at Starbucks BGC. Let me know if you need to reschedule. See you!',
      classification: ThreatClassification.legitimate,
      confidence: 0.87,
      detectionReasons: [
        'Personal message format',
        'No suspicious elements',
        'Normal conversation',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  // Mock Call data
  static final List<CallDetection> _mockCallData = [
    CallDetection(
      id: 'c1',
      callerNumber: '+639281234567',
      transcriptPreview:
          'Hello sir, this is from LBC courier. You have a pending delivery that requires payment...',
      fullTranscript:
          'Hello sir, good morning. This is from LBC courier service. You have a pending delivery from China that requires immediate payment of 2,500 pesos for customs clearance. Please send payment to our GCash number 09281234567. Without payment, your package will be returned to sender tomorrow.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.94,
      detectionReasons: [
        'High-pressure sales tactics detected',
        'Requests money transfer via mobile payment',
        'Impersonates legitimate courier service',
        'Background noise inconsistent with call center',
        'Creates artificial urgency',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      duration: 127,
    ),
    CallDetection(
      id: 'c2',
      callerNumber: '+639171234568',
      transcriptPreview:
          'This is BDO security department. We detected suspicious activity on your account...',
      fullTranscript:
          'Good afternoon, this is Kristine from BDO security department. We detected suspicious activity on your account ending in 4567. Someone tried to transfer 50,000 pesos. To secure your account, I need to verify your OTP code that we just sent. Can you please provide the 6-digit code?',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.97,
      detectionReasons: [
        'Requests OTP code (banks never ask for this)',
        'Creates panic with fake security alert',
        'Impersonates bank personnel',
        'Voice stress analysis indicates deception',
        'Classic social engineering attack',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      duration: 184,
    ),
    CallDetection(
      id: 'c3',
      callerNumber: '+639991234569',
      transcriptPreview:
          'Congratulations! You won 1 million pesos in our raffle. To claim, you need to pay tax first...',
      fullTranscript:
          'Hello! Congratulations! You are the lucky winner of 1 million pesos in SM Megamall anniversary raffle draw. Your name was selected from our customer database. To claim your prize, you need to pay 15,000 pesos processing fee and withholding tax. You can pay via bank deposit or GCash. Should I give you the account details?',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.96,
      detectionReasons: [
        'Classic advance-fee fraud',
        'Requests payment to claim prize',
        'No legitimate raffle requires upfront payment',
        'Too good to be true offer',
        'Caller shows typical scammer patterns',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      duration: 215,
    ),
    CallDetection(
      id: 'c4',
      callerNumber: '+639181234570',
      transcriptPreview:
          'SSS calling. Your account will be suspended unless you update information today...',
      fullTranscript:
          'This is Social Security System calling regarding your SSS account. Our records show that your information is outdated and your account will be suspended today unless you update it immediately. I can help you update now over the phone. I need your SSS number, date of birth, and mother\'s maiden name for verification.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.95,
      detectionReasons: [
        'Impersonates government agency',
        'Requests sensitive personal information',
        'Creates false urgency (suspension today)',
        'SSS doesn\'t make unsolicited calls',
        'Phishing attempt via phone',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      duration: 156,
    ),
    CallDetection(
      id: 'c5',
      callerNumber: '+639201234571',
      transcriptPreview:
          'This is NBI. You have pending case. You must settle 50,000 pesos or face arrest...',
      fullTranscript:
          'This is Officer Rodriguez from National Bureau of Investigation. You have a pending criminal case filed against you for identity theft. To avoid arrest warrant, you must settle 50,000 pesos penalty today. I can guide you on payment process. This is confidential matter, do not tell anyone.',
      classification: ThreatClassification.confirmedScam,
      confidence: 0.98,
      detectionReasons: [
        'Fake law enforcement threat',
        'Demands immediate payment',
        'Instructs victim to keep secret',
        'NBI doesn\'t operate this way',
        'Classic intimidation scam',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      duration: 198,
    ),

    // SUSPICIOUS CALLS
    CallDetection(
      id: 'c6',
      callerNumber: '+639301234573',
      transcriptPreview:
          'Investment opportunity! Triple your money in 30 days. Risk-free guaranteed returns...',
      fullTranscript:
          'Good day! I\'m calling from Premium Investment Corporation. We have exclusive investment opportunity that can triple your money in just 30 days. It\'s risk-free with guaranteed returns. Minimum investment is only 20,000 pesos. We have limited slots. Are you interested?',
      classification: ThreatClassification.suspicious,
      confidence: 0.79,
      detectionReasons: [
        'Unsolicited investment call',
        'Unrealistic returns promised',
        'Pressure to invest quickly',
        'Should verify company legitimacy',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      duration: 143,
    ),
    CallDetection(
      id: 'c7',
      callerNumber: '+639401234574',
      transcriptPreview:
          'You pre-qualified for 100k loan. No requirements needed. Approve now...',
      fullTranscript:
          'Congratulations! You are pre-qualified for 100,000 pesos personal loan with very low interest. No requirements needed, instant approval. Just pay 3,000 pesos processing fee first then loan will be released immediately to your account. Interested?',
      classification: ThreatClassification.suspicious,
      confidence: 0.76,
      detectionReasons: [
        'Unsolicited loan offer',
        'Requests upfront fee',
        'Too easy qualification',
        'Possibly predatory lending',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      duration: 167,
    ),

    // LEGITIMATE CALLS
    CallDetection(
      id: 'c8',
      callerNumber: '+632123456789',
      transcriptPreview:
          'This is Shopee customer service regarding your order inquiry...',
      fullTranscript:
          'Hello, this is Amanda from Shopee customer service. I\'m calling regarding your inquiry about order SP2024121545678. The seller has confirmed that your item will be shipped tomorrow. Estimated delivery is 3-5 business days. Is there anything else I can help you with?',
      classification: ThreatClassification.legitimate,
      confidence: 0.88,
      detectionReasons: [
        'Expected follow-up call',
        'References specific order',
        'Professional call center environment',
        'No requests for payment or personal info',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      duration: 98,
    ),
    CallDetection(
      id: 'c9',
      callerNumber: '+632987654321',
      transcriptPreview:
          'Reminder: Your dental appointment is tomorrow at 2pm. Please confirm attendance...',
      fullTranscript:
          'Good afternoon! This is Smile Dental Clinic calling to remind you about your appointment tomorrow, December 16 at 2:00 PM with Dr. Santos. Please confirm if you can make it or if you need to reschedule. You can also confirm via our website. Thank you!',
      classification: ThreatClassification.legitimate,
      confidence: 0.91,
      detectionReasons: [
        'Legitimate appointment reminder',
        'From known healthcare provider',
        'Professional automated system',
        'No suspicious requests',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      duration: 65,
    ),
    CallDetection(
      id: 'c10',
      callerNumber: '+639876543210',
      transcriptPreview:
          'Hi! Just calling to check if you received my message about tomorrow\'s meeting...',
      fullTranscript:
          'Hi! Just calling to check if you received my text message about tomorrow\'s meeting at Starbucks BGC at 3pm. Let me know if that still works for you or if we need to change the time. Thanks!',
      classification: ThreatClassification.legitimate,
      confidence: 0.87,
      detectionReasons: [
        'Personal call from known contact',
        'Normal conversation pattern',
        'No suspicious elements',
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      duration: 52,
    ),
  ];
}
