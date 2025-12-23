class Console {
  Console(
      {this.name,
      this.altName,
      this.slug,
      this.fromExternalSource,
      this.description,
      this.logoUrl});
  String? name;
  String? slug;
  String? altName;
  String? description;
  String? logoUrl;
  bool? fromExternalSource;
}
