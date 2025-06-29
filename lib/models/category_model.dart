class Category {
  final String name;
  final String icon;
  final List<String> keywords;

  Category({required this.name, required this.icon, required this.keywords});
}

// Software engineering categories
final List<Category> softwareCategories = [
  Category(
    name: 'All',
    icon: '🌐',
    keywords: ['technology', 'tech', 'software', 'programming', 'development'],
  ),
  Category(
    name: 'Backend',
    icon: '🖥️',
    keywords: [
      'backend',
      'server',
      'api',
      'database',
      'cloud',
      'microservices',
    ],
  ),
  Category(
    name: 'Frontend',
    icon: '🎨',
    keywords: [
      'frontend',
      'ui',
      'ux',
      'web',
      'design',
      'javascript',
      'html',
      'css',
    ],
  ),
  Category(
    name: 'Mobile',
    icon: '📱',
    keywords: [
      'mobile',
      'android',
      'ios',
      'flutter',
      'react native',
      'swift',
      'kotlin',
    ],
  ),
  Category(
    name: 'DevOps',
    icon: '⚙️',
    keywords: [
      'devops',
      'ci/cd',
      'docker',
      'kubernetes',
      'deployment',
      'automation',
    ],
  ),
  Category(
    name: 'AI/ML',
    icon: '🤖',
    keywords: [
      'ai',
      'machine learning',
      'deep learning',
      'neural networks',
      'data science',
    ],
  ),
  Category(
    name: 'Databases',
    icon: '🗃️',
    keywords: [
      'database',
      'sql',
      'nosql',
      'mongodb',
      'postgresql',
      'mysql',
      'redis',
    ],
  ),
  Category(
    name: 'Cloud',
    icon: '☁️',
    keywords: [
      'cloud',
      'aws',
      'azure',
      'gcp',
      'serverless',
      'iaas',
      'paas',
      'saas',
    ],
  ),
  Category(
    name: 'Security',
    icon: '🔒',
    keywords: [
      'security',
      'cybersecurity',
      'hacking',
      'encryption',
      'authentication',
    ],
  ),
];
