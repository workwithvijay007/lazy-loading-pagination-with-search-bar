class Country {
  final String name;
  final int population2020;
  final String yearlyChange;
  final int netChange;
  final int density;
  final int landArea;
  final int migrants;
  final double fertilityRate;
  final int medianAge;
  final String urbanPopulationPercentage;
  final String worldShare;

  Country({
    required this.name,
    required this.population2020,
    required this.yearlyChange,
    required this.netChange,
    required this.density,
    required this.landArea,
    required this.migrants,
    required this.fertilityRate,
    required this.medianAge,
    required this.urbanPopulationPercentage,
    required this.worldShare,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['Country (or dependency)'],
      population2020: json['Population (2020)'],
      yearlyChange: json['Yearly Change'],
      netChange: json['Net Change'],
      density: json['Density (P/Km²)'],
      landArea: json['Land Area (Km²)'],
      migrants: json['Migrants (net)'],
      fertilityRate: json['Fert. Rate'].toDouble(),
      medianAge: json['Med. Age'],
      urbanPopulationPercentage: json['Urban Pop %'],
      worldShare: json['World Share'],
    );
  }
}
