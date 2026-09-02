// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Categorie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconeMeta = const VerificationMeta('icone');
  @override
  late final GeneratedColumn<String> icone = GeneratedColumn<String>(
    'icone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _estParDefautMeta = const VerificationMeta(
    'estParDefaut',
  );
  @override
  late final GeneratedColumn<bool> estParDefaut = GeneratedColumn<bool>(
    'est_par_defaut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("est_par_defaut" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nom, icone, estParDefaut];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorie';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categorie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('icone')) {
      context.handle(
        _iconeMeta,
        icone.isAcceptableOrUnknown(data['icone']!, _iconeMeta),
      );
    }
    if (data.containsKey('est_par_defaut')) {
      context.handle(
        _estParDefautMeta,
        estParDefaut.isAcceptableOrUnknown(
          data['est_par_defaut']!,
          _estParDefautMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nom},
  ];
  @override
  Categorie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categorie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      icone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icone'],
      )!,
      estParDefaut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}est_par_defaut'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Categorie extends DataClass implements Insertable<Categorie> {
  final int id;
  final String nom;
  final String icone;

  /// Catégorie "Non classé" (seed initial) : non supprimable, cible de
  /// réaffectation automatique. Absent du schéma documenté tel quel ; ajouté
  /// ici par symétrie avec `Zone.is_root` pour ne pas dépendre du nom
  /// (qui reste modifiable, cf. cahier-des-charges.md §8.2 pour le pattern
  /// équivalent sur Zone).
  final bool estParDefaut;
  const Categorie({
    required this.id,
    required this.nom,
    required this.icone,
    required this.estParDefaut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['icone'] = Variable<String>(icone);
    map['est_par_defaut'] = Variable<bool>(estParDefaut);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      nom: Value(nom),
      icone: Value(icone),
      estParDefaut: Value(estParDefaut),
    );
  }

  factory Categorie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categorie(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      icone: serializer.fromJson<String>(json['icone']),
      estParDefaut: serializer.fromJson<bool>(json['estParDefaut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'icone': serializer.toJson<String>(icone),
      'estParDefaut': serializer.toJson<bool>(estParDefaut),
    };
  }

  Categorie copyWith({
    int? id,
    String? nom,
    String? icone,
    bool? estParDefaut,
  }) => Categorie(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    icone: icone ?? this.icone,
    estParDefaut: estParDefaut ?? this.estParDefaut,
  );
  Categorie copyWithCompanion(CategoriesCompanion data) {
    return Categorie(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      icone: data.icone.present ? data.icone.value : this.icone,
      estParDefaut: data.estParDefaut.present
          ? data.estParDefaut.value
          : this.estParDefaut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categorie(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone, ')
          ..write('estParDefaut: $estParDefaut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, icone, estParDefaut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categorie &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.icone == this.icone &&
          other.estParDefaut == this.estParDefaut);
}

class CategoriesCompanion extends UpdateCompanion<Categorie> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String> icone;
  final Value<bool> estParDefaut;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.icone = const Value.absent(),
    this.estParDefaut = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.icone = const Value.absent(),
    this.estParDefaut = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Categorie> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? icone,
    Expression<bool>? estParDefaut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (icone != null) 'icone': icone,
      if (estParDefaut != null) 'est_par_defaut': estParDefaut,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<String>? icone,
    Value<bool>? estParDefaut,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      icone: icone ?? this.icone,
      estParDefaut: estParDefaut ?? this.estParDefaut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (icone.present) {
      map['icone'] = Variable<String>(icone.value);
    }
    if (estParDefaut.present) {
      map['est_par_defaut'] = Variable<bool>(estParDefaut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone, ')
          ..write('estParDefaut: $estParDefaut')
          ..write(')'))
        .toString();
  }
}

class $ZonesTable extends Zones with TableInfo<$ZonesTable, Zone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconeMeta = const VerificationMeta('icone');
  @override
  late final GeneratedColumn<String> icone = GeneratedColumn<String>(
    'icone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('kitchen'),
  );
  static const VerificationMeta _isRootMeta = const VerificationMeta('isRoot');
  @override
  late final GeneratedColumn<bool> isRoot = GeneratedColumn<bool>(
    'is_root',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_root" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, nom, icone, isRoot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zone';
  @override
  VerificationContext validateIntegrity(
    Insertable<Zone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('icone')) {
      context.handle(
        _iconeMeta,
        icone.isAcceptableOrUnknown(data['icone']!, _iconeMeta),
      );
    }
    if (data.containsKey('is_root')) {
      context.handle(
        _isRootMeta,
        isRoot.isAcceptableOrUnknown(data['is_root']!, _isRootMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nom},
  ];
  @override
  Zone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Zone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      icone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icone'],
      )!,
      isRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_root'],
      )!,
    );
  }

  @override
  $ZonesTable createAlias(String alias) {
    return $ZonesTable(attachedDatabase, alias);
  }
}

class Zone extends DataClass implements Insertable<Zone> {
  final int id;
  final String nom;
  final String icone;

  /// Zone racine "Frigo" (seed initial) : modifiable mais non supprimable,
  /// cible de réaffectation. Cf. cahier-des-charges.md §8.2.
  final bool isRoot;
  const Zone({
    required this.id,
    required this.nom,
    required this.icone,
    required this.isRoot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['icone'] = Variable<String>(icone);
    map['is_root'] = Variable<bool>(isRoot);
    return map;
  }

  ZonesCompanion toCompanion(bool nullToAbsent) {
    return ZonesCompanion(
      id: Value(id),
      nom: Value(nom),
      icone: Value(icone),
      isRoot: Value(isRoot),
    );
  }

  factory Zone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Zone(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      icone: serializer.fromJson<String>(json['icone']),
      isRoot: serializer.fromJson<bool>(json['isRoot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'icone': serializer.toJson<String>(icone),
      'isRoot': serializer.toJson<bool>(isRoot),
    };
  }

  Zone copyWith({int? id, String? nom, String? icone, bool? isRoot}) => Zone(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    icone: icone ?? this.icone,
    isRoot: isRoot ?? this.isRoot,
  );
  Zone copyWithCompanion(ZonesCompanion data) {
    return Zone(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      icone: data.icone.present ? data.icone.value : this.icone,
      isRoot: data.isRoot.present ? data.isRoot.value : this.isRoot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Zone(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone, ')
          ..write('isRoot: $isRoot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, icone, isRoot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zone &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.icone == this.icone &&
          other.isRoot == this.isRoot);
}

class ZonesCompanion extends UpdateCompanion<Zone> {
  final Value<int> id;
  final Value<String> nom;
  final Value<String> icone;
  final Value<bool> isRoot;
  const ZonesCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.icone = const Value.absent(),
    this.isRoot = const Value.absent(),
  });
  ZonesCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.icone = const Value.absent(),
    this.isRoot = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Zone> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? icone,
    Expression<bool>? isRoot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (icone != null) 'icone': icone,
      if (isRoot != null) 'is_root': isRoot,
    });
  }

  ZonesCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<String>? icone,
    Value<bool>? isRoot,
  }) {
    return ZonesCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      icone: icone ?? this.icone,
      isRoot: isRoot ?? this.isRoot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (icone.present) {
      map['icone'] = Variable<String>(icone.value);
    }
    if (isRoot.present) {
      map['is_root'] = Variable<bool>(isRoot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('icone: $icone, ')
          ..write('isRoot: $isRoot')
          ..write(')'))
        .toString();
  }
}

class $UnitesTable extends Unites with TableInfo<$UnitesTable, Unite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TypeGrandeur, String>
  typeGrandeur = GeneratedColumn<String>(
    'type_grandeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TypeGrandeur>($UnitesTable.$convertertypeGrandeur);
  static const VerificationMeta _facteurVersBaseMeta = const VerificationMeta(
    'facteurVersBase',
  );
  @override
  late final GeneratedColumn<double> facteurVersBase = GeneratedColumn<double>(
    'facteur_vers_base',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    typeGrandeur,
    facteurVersBase,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unite';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('facteur_vers_base')) {
      context.handle(
        _facteurVersBaseMeta,
        facteurVersBase.isAcceptableOrUnknown(
          data['facteur_vers_base']!,
          _facteurVersBaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facteurVersBaseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nom},
  ];
  @override
  Unite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      typeGrandeur: $UnitesTable.$convertertypeGrandeur.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type_grandeur'],
        )!,
      ),
      facteurVersBase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}facteur_vers_base'],
      )!,
    );
  }

  @override
  $UnitesTable createAlias(String alias) {
    return $UnitesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TypeGrandeur, String, String>
  $convertertypeGrandeur = const EnumNameConverter<TypeGrandeur>(
    TypeGrandeur.values,
  );
}

class Unite extends DataClass implements Insertable<Unite> {
  final int id;
  final String nom;
  final TypeGrandeur typeGrandeur;

  /// Facteur de conversion vers l'unité de base de son `typeGrandeur`.
  final double facteurVersBase;
  const Unite({
    required this.id,
    required this.nom,
    required this.typeGrandeur,
    required this.facteurVersBase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    {
      map['type_grandeur'] = Variable<String>(
        $UnitesTable.$convertertypeGrandeur.toSql(typeGrandeur),
      );
    }
    map['facteur_vers_base'] = Variable<double>(facteurVersBase);
    return map;
  }

  UnitesCompanion toCompanion(bool nullToAbsent) {
    return UnitesCompanion(
      id: Value(id),
      nom: Value(nom),
      typeGrandeur: Value(typeGrandeur),
      facteurVersBase: Value(facteurVersBase),
    );
  }

  factory Unite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unite(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      typeGrandeur: $UnitesTable.$convertertypeGrandeur.fromJson(
        serializer.fromJson<String>(json['typeGrandeur']),
      ),
      facteurVersBase: serializer.fromJson<double>(json['facteurVersBase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'typeGrandeur': serializer.toJson<String>(
        $UnitesTable.$convertertypeGrandeur.toJson(typeGrandeur),
      ),
      'facteurVersBase': serializer.toJson<double>(facteurVersBase),
    };
  }

  Unite copyWith({
    int? id,
    String? nom,
    TypeGrandeur? typeGrandeur,
    double? facteurVersBase,
  }) => Unite(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    typeGrandeur: typeGrandeur ?? this.typeGrandeur,
    facteurVersBase: facteurVersBase ?? this.facteurVersBase,
  );
  Unite copyWithCompanion(UnitesCompanion data) {
    return Unite(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      typeGrandeur: data.typeGrandeur.present
          ? data.typeGrandeur.value
          : this.typeGrandeur,
      facteurVersBase: data.facteurVersBase.present
          ? data.facteurVersBase.value
          : this.facteurVersBase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unite(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('typeGrandeur: $typeGrandeur, ')
          ..write('facteurVersBase: $facteurVersBase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, typeGrandeur, facteurVersBase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unite &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.typeGrandeur == this.typeGrandeur &&
          other.facteurVersBase == this.facteurVersBase);
}

class UnitesCompanion extends UpdateCompanion<Unite> {
  final Value<int> id;
  final Value<String> nom;
  final Value<TypeGrandeur> typeGrandeur;
  final Value<double> facteurVersBase;
  const UnitesCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.typeGrandeur = const Value.absent(),
    this.facteurVersBase = const Value.absent(),
  });
  UnitesCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    required TypeGrandeur typeGrandeur,
    required double facteurVersBase,
  }) : nom = Value(nom),
       typeGrandeur = Value(typeGrandeur),
       facteurVersBase = Value(facteurVersBase);
  static Insertable<Unite> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<String>? typeGrandeur,
    Expression<double>? facteurVersBase,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (typeGrandeur != null) 'type_grandeur': typeGrandeur,
      if (facteurVersBase != null) 'facteur_vers_base': facteurVersBase,
    });
  }

  UnitesCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<TypeGrandeur>? typeGrandeur,
    Value<double>? facteurVersBase,
  }) {
    return UnitesCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      typeGrandeur: typeGrandeur ?? this.typeGrandeur,
      facteurVersBase: facteurVersBase ?? this.facteurVersBase,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (typeGrandeur.present) {
      map['type_grandeur'] = Variable<String>(
        $UnitesTable.$convertertypeGrandeur.toSql(typeGrandeur.value),
      );
    }
    if (facteurVersBase.present) {
      map['facteur_vers_base'] = Variable<double>(facteurVersBase.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitesCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('typeGrandeur: $typeGrandeur, ')
          ..write('facteurVersBase: $facteurVersBase')
          ..write(')'))
        .toString();
  }
}

class $ProduitsTable extends Produits with TableInfo<$ProduitsTable, Produit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categorieIdMeta = const VerificationMeta(
    'categorieId',
  );
  @override
  late final GeneratedColumn<int> categorieId = GeneratedColumn<int>(
    'categorie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorie (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TypeGrandeur, String>
  typeGrandeur = GeneratedColumn<String>(
    'type_grandeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TypeGrandeur>($ProduitsTable.$convertertypeGrandeur);
  static const VerificationMeta _uniteDefautIdMeta = const VerificationMeta(
    'uniteDefautId',
  );
  @override
  late final GeneratedColumn<int> uniteDefautId = GeneratedColumn<int>(
    'unite_defaut_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unite (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatutProduit, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(StatutProduit.actif.name),
      ).withConverter<StatutProduit>($ProduitsTable.$converterstatut);
  static const VerificationMeta _dateDerniereUtilisationMeta =
      const VerificationMeta('dateDerniereUtilisation');
  @override
  late final GeneratedColumn<DateTime> dateDerniereUtilisation =
      GeneratedColumn<DateTime>(
        'date_derniere_utilisation',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _codeBarreMeta = const VerificationMeta(
    'codeBarre',
  );
  @override
  late final GeneratedColumn<String> codeBarre = GeneratedColumn<String>(
    'code_barre',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 8,
      maxTextLength: 14,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    categorieId,
    typeGrandeur,
    uniteDefautId,
    statut,
    dateDerniereUtilisation,
    codeBarre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produit';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('categorie_id')) {
      context.handle(
        _categorieIdMeta,
        categorieId.isAcceptableOrUnknown(
          data['categorie_id']!,
          _categorieIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categorieIdMeta);
    }
    if (data.containsKey('unite_defaut_id')) {
      context.handle(
        _uniteDefautIdMeta,
        uniteDefautId.isAcceptableOrUnknown(
          data['unite_defaut_id']!,
          _uniteDefautIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uniteDefautIdMeta);
    }
    if (data.containsKey('date_derniere_utilisation')) {
      context.handle(
        _dateDerniereUtilisationMeta,
        dateDerniereUtilisation.isAcceptableOrUnknown(
          data['date_derniere_utilisation']!,
          _dateDerniereUtilisationMeta,
        ),
      );
    }
    if (data.containsKey('code_barre')) {
      context.handle(
        _codeBarreMeta,
        codeBarre.isAcceptableOrUnknown(data['code_barre']!, _codeBarreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nom},
  ];
  @override
  Produit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      categorieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categorie_id'],
      )!,
      typeGrandeur: $ProduitsTable.$convertertypeGrandeur.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type_grandeur'],
        )!,
      ),
      uniteDefautId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unite_defaut_id'],
      )!,
      statut: $ProduitsTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      dateDerniereUtilisation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_derniere_utilisation'],
      ),
      codeBarre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_barre'],
      ),
    );
  }

  @override
  $ProduitsTable createAlias(String alias) {
    return $ProduitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TypeGrandeur, String, String>
  $convertertypeGrandeur = const EnumNameConverter<TypeGrandeur>(
    TypeGrandeur.values,
  );
  static JsonTypeConverter2<StatutProduit, String, String> $converterstatut =
      const EnumNameConverter<StatutProduit>(StatutProduit.values);
}

class Produit extends DataClass implements Insertable<Produit> {
  final int id;
  final String nom;
  final int categorieId;

  /// Fixe pour un produit donné, non modifiable après création
  /// (cf. documentation-technique.md §2 "Produit").
  final TypeGrandeur typeGrandeur;
  final int uniteDefautId;
  final StatutProduit statut;
  final DateTime? dateDerniereUtilisation;

  /// Code-barres EAN‑13/EAN‑8/UPC‑A/ITF‑14 renseigné via le scan (évolution
  /// v1.1, cf. Docs/poc-scan-code-barres.md). Sert de cache de reconnaissance :
  /// un code déjà connu retrouve le produit sans réseau. Nullable — tous les
  /// produits n'ont pas de code (vrac, fait maison) ; l'index UNIQUE ignore les
  /// NULL (comportement SQLite standard), donc plusieurs produits « sans code »
  /// coexistent. Ajouté par la migration de schéma v1 → v2.
  final String? codeBarre;
  const Produit({
    required this.id,
    required this.nom,
    required this.categorieId,
    required this.typeGrandeur,
    required this.uniteDefautId,
    required this.statut,
    this.dateDerniereUtilisation,
    this.codeBarre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['categorie_id'] = Variable<int>(categorieId);
    {
      map['type_grandeur'] = Variable<String>(
        $ProduitsTable.$convertertypeGrandeur.toSql(typeGrandeur),
      );
    }
    map['unite_defaut_id'] = Variable<int>(uniteDefautId);
    {
      map['statut'] = Variable<String>(
        $ProduitsTable.$converterstatut.toSql(statut),
      );
    }
    if (!nullToAbsent || dateDerniereUtilisation != null) {
      map['date_derniere_utilisation'] = Variable<DateTime>(
        dateDerniereUtilisation,
      );
    }
    if (!nullToAbsent || codeBarre != null) {
      map['code_barre'] = Variable<String>(codeBarre);
    }
    return map;
  }

  ProduitsCompanion toCompanion(bool nullToAbsent) {
    return ProduitsCompanion(
      id: Value(id),
      nom: Value(nom),
      categorieId: Value(categorieId),
      typeGrandeur: Value(typeGrandeur),
      uniteDefautId: Value(uniteDefautId),
      statut: Value(statut),
      dateDerniereUtilisation: dateDerniereUtilisation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDerniereUtilisation),
      codeBarre: codeBarre == null && nullToAbsent
          ? const Value.absent()
          : Value(codeBarre),
    );
  }

  factory Produit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produit(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      categorieId: serializer.fromJson<int>(json['categorieId']),
      typeGrandeur: $ProduitsTable.$convertertypeGrandeur.fromJson(
        serializer.fromJson<String>(json['typeGrandeur']),
      ),
      uniteDefautId: serializer.fromJson<int>(json['uniteDefautId']),
      statut: $ProduitsTable.$converterstatut.fromJson(
        serializer.fromJson<String>(json['statut']),
      ),
      dateDerniereUtilisation: serializer.fromJson<DateTime?>(
        json['dateDerniereUtilisation'],
      ),
      codeBarre: serializer.fromJson<String?>(json['codeBarre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'categorieId': serializer.toJson<int>(categorieId),
      'typeGrandeur': serializer.toJson<String>(
        $ProduitsTable.$convertertypeGrandeur.toJson(typeGrandeur),
      ),
      'uniteDefautId': serializer.toJson<int>(uniteDefautId),
      'statut': serializer.toJson<String>(
        $ProduitsTable.$converterstatut.toJson(statut),
      ),
      'dateDerniereUtilisation': serializer.toJson<DateTime?>(
        dateDerniereUtilisation,
      ),
      'codeBarre': serializer.toJson<String?>(codeBarre),
    };
  }

  Produit copyWith({
    int? id,
    String? nom,
    int? categorieId,
    TypeGrandeur? typeGrandeur,
    int? uniteDefautId,
    StatutProduit? statut,
    Value<DateTime?> dateDerniereUtilisation = const Value.absent(),
    Value<String?> codeBarre = const Value.absent(),
  }) => Produit(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    categorieId: categorieId ?? this.categorieId,
    typeGrandeur: typeGrandeur ?? this.typeGrandeur,
    uniteDefautId: uniteDefautId ?? this.uniteDefautId,
    statut: statut ?? this.statut,
    dateDerniereUtilisation: dateDerniereUtilisation.present
        ? dateDerniereUtilisation.value
        : this.dateDerniereUtilisation,
    codeBarre: codeBarre.present ? codeBarre.value : this.codeBarre,
  );
  Produit copyWithCompanion(ProduitsCompanion data) {
    return Produit(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      categorieId: data.categorieId.present
          ? data.categorieId.value
          : this.categorieId,
      typeGrandeur: data.typeGrandeur.present
          ? data.typeGrandeur.value
          : this.typeGrandeur,
      uniteDefautId: data.uniteDefautId.present
          ? data.uniteDefautId.value
          : this.uniteDefautId,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateDerniereUtilisation: data.dateDerniereUtilisation.present
          ? data.dateDerniereUtilisation.value
          : this.dateDerniereUtilisation,
      codeBarre: data.codeBarre.present ? data.codeBarre.value : this.codeBarre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produit(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('categorieId: $categorieId, ')
          ..write('typeGrandeur: $typeGrandeur, ')
          ..write('uniteDefautId: $uniteDefautId, ')
          ..write('statut: $statut, ')
          ..write('dateDerniereUtilisation: $dateDerniereUtilisation, ')
          ..write('codeBarre: $codeBarre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nom,
    categorieId,
    typeGrandeur,
    uniteDefautId,
    statut,
    dateDerniereUtilisation,
    codeBarre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produit &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.categorieId == this.categorieId &&
          other.typeGrandeur == this.typeGrandeur &&
          other.uniteDefautId == this.uniteDefautId &&
          other.statut == this.statut &&
          other.dateDerniereUtilisation == this.dateDerniereUtilisation &&
          other.codeBarre == this.codeBarre);
}

class ProduitsCompanion extends UpdateCompanion<Produit> {
  final Value<int> id;
  final Value<String> nom;
  final Value<int> categorieId;
  final Value<TypeGrandeur> typeGrandeur;
  final Value<int> uniteDefautId;
  final Value<StatutProduit> statut;
  final Value<DateTime?> dateDerniereUtilisation;
  final Value<String?> codeBarre;
  const ProduitsCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.categorieId = const Value.absent(),
    this.typeGrandeur = const Value.absent(),
    this.uniteDefautId = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateDerniereUtilisation = const Value.absent(),
    this.codeBarre = const Value.absent(),
  });
  ProduitsCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    required int categorieId,
    required TypeGrandeur typeGrandeur,
    required int uniteDefautId,
    this.statut = const Value.absent(),
    this.dateDerniereUtilisation = const Value.absent(),
    this.codeBarre = const Value.absent(),
  }) : nom = Value(nom),
       categorieId = Value(categorieId),
       typeGrandeur = Value(typeGrandeur),
       uniteDefautId = Value(uniteDefautId);
  static Insertable<Produit> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<int>? categorieId,
    Expression<String>? typeGrandeur,
    Expression<int>? uniteDefautId,
    Expression<String>? statut,
    Expression<DateTime>? dateDerniereUtilisation,
    Expression<String>? codeBarre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (categorieId != null) 'categorie_id': categorieId,
      if (typeGrandeur != null) 'type_grandeur': typeGrandeur,
      if (uniteDefautId != null) 'unite_defaut_id': uniteDefautId,
      if (statut != null) 'statut': statut,
      if (dateDerniereUtilisation != null)
        'date_derniere_utilisation': dateDerniereUtilisation,
      if (codeBarre != null) 'code_barre': codeBarre,
    });
  }

  ProduitsCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<int>? categorieId,
    Value<TypeGrandeur>? typeGrandeur,
    Value<int>? uniteDefautId,
    Value<StatutProduit>? statut,
    Value<DateTime?>? dateDerniereUtilisation,
    Value<String?>? codeBarre,
  }) {
    return ProduitsCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      categorieId: categorieId ?? this.categorieId,
      typeGrandeur: typeGrandeur ?? this.typeGrandeur,
      uniteDefautId: uniteDefautId ?? this.uniteDefautId,
      statut: statut ?? this.statut,
      dateDerniereUtilisation:
          dateDerniereUtilisation ?? this.dateDerniereUtilisation,
      codeBarre: codeBarre ?? this.codeBarre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (categorieId.present) {
      map['categorie_id'] = Variable<int>(categorieId.value);
    }
    if (typeGrandeur.present) {
      map['type_grandeur'] = Variable<String>(
        $ProduitsTable.$convertertypeGrandeur.toSql(typeGrandeur.value),
      );
    }
    if (uniteDefautId.present) {
      map['unite_defaut_id'] = Variable<int>(uniteDefautId.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $ProduitsTable.$converterstatut.toSql(statut.value),
      );
    }
    if (dateDerniereUtilisation.present) {
      map['date_derniere_utilisation'] = Variable<DateTime>(
        dateDerniereUtilisation.value,
      );
    }
    if (codeBarre.present) {
      map['code_barre'] = Variable<String>(codeBarre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduitsCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('categorieId: $categorieId, ')
          ..write('typeGrandeur: $typeGrandeur, ')
          ..write('uniteDefautId: $uniteDefautId, ')
          ..write('statut: $statut, ')
          ..write('dateDerniereUtilisation: $dateDerniereUtilisation, ')
          ..write('codeBarre: $codeBarre')
          ..write(')'))
        .toString();
  }
}

class $ProduitsFrigoTable extends ProduitsFrigo
    with TableInfo<$ProduitsFrigoTable, ProduitFrigo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduitsFrigoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<int> produitId = GeneratedColumn<int>(
    'produit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produit (id)',
    ),
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zone (id)',
    ),
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uniteIdMeta = const VerificationMeta(
    'uniteId',
  );
  @override
  late final GeneratedColumn<int> uniteId = GeneratedColumn<int>(
    'unite_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unite (id)',
    ),
  );
  static const VerificationMeta _dateAjoutMeta = const VerificationMeta(
    'dateAjout',
  );
  @override
  late final GeneratedColumn<DateTime> dateAjout = GeneratedColumn<DateTime>(
    'date_ajout',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datePeremptionMeta = const VerificationMeta(
    'datePeremption',
  );
  @override
  late final GeneratedColumn<DateTime> datePeremption =
      GeneratedColumn<DateTime>(
        'date_peremption',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<StatutProduitFrigo, String>
  statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(StatutProduitFrigo.enStock.name),
  ).withConverter<StatutProduitFrigo>($ProduitsFrigoTable.$converterstatut);
  static const VerificationMeta _dateStatutMeta = const VerificationMeta(
    'dateStatut',
  );
  @override
  late final GeneratedColumn<DateTime> dateStatut = GeneratedColumn<DateTime>(
    'date_statut',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    produitId,
    zoneId,
    quantite,
    uniteId,
    dateAjout,
    datePeremption,
    statut,
    dateStatut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produit_frigo';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProduitFrigo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_id')) {
      context.handle(
        _uniteIdMeta,
        uniteId.isAcceptableOrUnknown(data['unite_id']!, _uniteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_uniteIdMeta);
    }
    if (data.containsKey('date_ajout')) {
      context.handle(
        _dateAjoutMeta,
        dateAjout.isAcceptableOrUnknown(data['date_ajout']!, _dateAjoutMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAjoutMeta);
    }
    if (data.containsKey('date_peremption')) {
      context.handle(
        _datePeremptionMeta,
        datePeremption.isAcceptableOrUnknown(
          data['date_peremption']!,
          _datePeremptionMeta,
        ),
      );
    }
    if (data.containsKey('date_statut')) {
      context.handle(
        _dateStatutMeta,
        dateStatut.isAcceptableOrUnknown(data['date_statut']!, _dateStatutMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProduitFrigo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProduitFrigo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produit_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      uniteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unite_id'],
      )!,
      dateAjout: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_ajout'],
      )!,
      datePeremption: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_peremption'],
      ),
      statut: $ProduitsFrigoTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
      dateStatut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_statut'],
      ),
    );
  }

  @override
  $ProduitsFrigoTable createAlias(String alias) {
    return $ProduitsFrigoTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatutProduitFrigo, String, String>
  $converterstatut = const EnumNameConverter<StatutProduitFrigo>(
    StatutProduitFrigo.values,
  );
}

class ProduitFrigo extends DataClass implements Insertable<ProduitFrigo> {
  final int id;
  final int produitId;
  final int zoneId;
  final double quantite;
  final int uniteId;
  final DateTime dateAjout;
  final DateTime? datePeremption;
  final StatutProduitFrigo statut;

  /// Date du changement de statut (consommé/jeté), utilisée pour les
  /// statistiques anti-gaspi (hors MVP v1, cf. documentation-technique.md §5).
  final DateTime? dateStatut;
  const ProduitFrigo({
    required this.id,
    required this.produitId,
    required this.zoneId,
    required this.quantite,
    required this.uniteId,
    required this.dateAjout,
    this.datePeremption,
    required this.statut,
    this.dateStatut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['produit_id'] = Variable<int>(produitId);
    map['zone_id'] = Variable<int>(zoneId);
    map['quantite'] = Variable<double>(quantite);
    map['unite_id'] = Variable<int>(uniteId);
    map['date_ajout'] = Variable<DateTime>(dateAjout);
    if (!nullToAbsent || datePeremption != null) {
      map['date_peremption'] = Variable<DateTime>(datePeremption);
    }
    {
      map['statut'] = Variable<String>(
        $ProduitsFrigoTable.$converterstatut.toSql(statut),
      );
    }
    if (!nullToAbsent || dateStatut != null) {
      map['date_statut'] = Variable<DateTime>(dateStatut);
    }
    return map;
  }

  ProduitsFrigoCompanion toCompanion(bool nullToAbsent) {
    return ProduitsFrigoCompanion(
      id: Value(id),
      produitId: Value(produitId),
      zoneId: Value(zoneId),
      quantite: Value(quantite),
      uniteId: Value(uniteId),
      dateAjout: Value(dateAjout),
      datePeremption: datePeremption == null && nullToAbsent
          ? const Value.absent()
          : Value(datePeremption),
      statut: Value(statut),
      dateStatut: dateStatut == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStatut),
    );
  }

  factory ProduitFrigo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProduitFrigo(
      id: serializer.fromJson<int>(json['id']),
      produitId: serializer.fromJson<int>(json['produitId']),
      zoneId: serializer.fromJson<int>(json['zoneId']),
      quantite: serializer.fromJson<double>(json['quantite']),
      uniteId: serializer.fromJson<int>(json['uniteId']),
      dateAjout: serializer.fromJson<DateTime>(json['dateAjout']),
      datePeremption: serializer.fromJson<DateTime?>(json['datePeremption']),
      statut: $ProduitsFrigoTable.$converterstatut.fromJson(
        serializer.fromJson<String>(json['statut']),
      ),
      dateStatut: serializer.fromJson<DateTime?>(json['dateStatut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'produitId': serializer.toJson<int>(produitId),
      'zoneId': serializer.toJson<int>(zoneId),
      'quantite': serializer.toJson<double>(quantite),
      'uniteId': serializer.toJson<int>(uniteId),
      'dateAjout': serializer.toJson<DateTime>(dateAjout),
      'datePeremption': serializer.toJson<DateTime?>(datePeremption),
      'statut': serializer.toJson<String>(
        $ProduitsFrigoTable.$converterstatut.toJson(statut),
      ),
      'dateStatut': serializer.toJson<DateTime?>(dateStatut),
    };
  }

  ProduitFrigo copyWith({
    int? id,
    int? produitId,
    int? zoneId,
    double? quantite,
    int? uniteId,
    DateTime? dateAjout,
    Value<DateTime?> datePeremption = const Value.absent(),
    StatutProduitFrigo? statut,
    Value<DateTime?> dateStatut = const Value.absent(),
  }) => ProduitFrigo(
    id: id ?? this.id,
    produitId: produitId ?? this.produitId,
    zoneId: zoneId ?? this.zoneId,
    quantite: quantite ?? this.quantite,
    uniteId: uniteId ?? this.uniteId,
    dateAjout: dateAjout ?? this.dateAjout,
    datePeremption: datePeremption.present
        ? datePeremption.value
        : this.datePeremption,
    statut: statut ?? this.statut,
    dateStatut: dateStatut.present ? dateStatut.value : this.dateStatut,
  );
  ProduitFrigo copyWithCompanion(ProduitsFrigoCompanion data) {
    return ProduitFrigo(
      id: data.id.present ? data.id.value : this.id,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteId: data.uniteId.present ? data.uniteId.value : this.uniteId,
      dateAjout: data.dateAjout.present ? data.dateAjout.value : this.dateAjout,
      datePeremption: data.datePeremption.present
          ? data.datePeremption.value
          : this.datePeremption,
      statut: data.statut.present ? data.statut.value : this.statut,
      dateStatut: data.dateStatut.present
          ? data.dateStatut.value
          : this.dateStatut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProduitFrigo(')
          ..write('id: $id, ')
          ..write('produitId: $produitId, ')
          ..write('zoneId: $zoneId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId, ')
          ..write('dateAjout: $dateAjout, ')
          ..write('datePeremption: $datePeremption, ')
          ..write('statut: $statut, ')
          ..write('dateStatut: $dateStatut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    produitId,
    zoneId,
    quantite,
    uniteId,
    dateAjout,
    datePeremption,
    statut,
    dateStatut,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProduitFrigo &&
          other.id == this.id &&
          other.produitId == this.produitId &&
          other.zoneId == this.zoneId &&
          other.quantite == this.quantite &&
          other.uniteId == this.uniteId &&
          other.dateAjout == this.dateAjout &&
          other.datePeremption == this.datePeremption &&
          other.statut == this.statut &&
          other.dateStatut == this.dateStatut);
}

class ProduitsFrigoCompanion extends UpdateCompanion<ProduitFrigo> {
  final Value<int> id;
  final Value<int> produitId;
  final Value<int> zoneId;
  final Value<double> quantite;
  final Value<int> uniteId;
  final Value<DateTime> dateAjout;
  final Value<DateTime?> datePeremption;
  final Value<StatutProduitFrigo> statut;
  final Value<DateTime?> dateStatut;
  const ProduitsFrigoCompanion({
    this.id = const Value.absent(),
    this.produitId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteId = const Value.absent(),
    this.dateAjout = const Value.absent(),
    this.datePeremption = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateStatut = const Value.absent(),
  });
  ProduitsFrigoCompanion.insert({
    this.id = const Value.absent(),
    required int produitId,
    required int zoneId,
    required double quantite,
    required int uniteId,
    required DateTime dateAjout,
    this.datePeremption = const Value.absent(),
    this.statut = const Value.absent(),
    this.dateStatut = const Value.absent(),
  }) : produitId = Value(produitId),
       zoneId = Value(zoneId),
       quantite = Value(quantite),
       uniteId = Value(uniteId),
       dateAjout = Value(dateAjout);
  static Insertable<ProduitFrigo> custom({
    Expression<int>? id,
    Expression<int>? produitId,
    Expression<int>? zoneId,
    Expression<double>? quantite,
    Expression<int>? uniteId,
    Expression<DateTime>? dateAjout,
    Expression<DateTime>? datePeremption,
    Expression<String>? statut,
    Expression<DateTime>? dateStatut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (produitId != null) 'produit_id': produitId,
      if (zoneId != null) 'zone_id': zoneId,
      if (quantite != null) 'quantite': quantite,
      if (uniteId != null) 'unite_id': uniteId,
      if (dateAjout != null) 'date_ajout': dateAjout,
      if (datePeremption != null) 'date_peremption': datePeremption,
      if (statut != null) 'statut': statut,
      if (dateStatut != null) 'date_statut': dateStatut,
    });
  }

  ProduitsFrigoCompanion copyWith({
    Value<int>? id,
    Value<int>? produitId,
    Value<int>? zoneId,
    Value<double>? quantite,
    Value<int>? uniteId,
    Value<DateTime>? dateAjout,
    Value<DateTime?>? datePeremption,
    Value<StatutProduitFrigo>? statut,
    Value<DateTime?>? dateStatut,
  }) {
    return ProduitsFrigoCompanion(
      id: id ?? this.id,
      produitId: produitId ?? this.produitId,
      zoneId: zoneId ?? this.zoneId,
      quantite: quantite ?? this.quantite,
      uniteId: uniteId ?? this.uniteId,
      dateAjout: dateAjout ?? this.dateAjout,
      datePeremption: datePeremption ?? this.datePeremption,
      statut: statut ?? this.statut,
      dateStatut: dateStatut ?? this.dateStatut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<int>(produitId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (uniteId.present) {
      map['unite_id'] = Variable<int>(uniteId.value);
    }
    if (dateAjout.present) {
      map['date_ajout'] = Variable<DateTime>(dateAjout.value);
    }
    if (datePeremption.present) {
      map['date_peremption'] = Variable<DateTime>(datePeremption.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $ProduitsFrigoTable.$converterstatut.toSql(statut.value),
      );
    }
    if (dateStatut.present) {
      map['date_statut'] = Variable<DateTime>(dateStatut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduitsFrigoCompanion(')
          ..write('id: $id, ')
          ..write('produitId: $produitId, ')
          ..write('zoneId: $zoneId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId, ')
          ..write('dateAjout: $dateAjout, ')
          ..write('datePeremption: $datePeremption, ')
          ..write('statut: $statut, ')
          ..write('dateStatut: $dateStatut')
          ..write(')'))
        .toString();
  }
}

class $PlatsTable extends Plats with TableInfo<$PlatsTable, Plat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempsPrepaMeta = const VerificationMeta(
    'tempsPrepa',
  );
  @override
  late final GeneratedColumn<int> tempsPrepa = GeneratedColumn<int>(
    'temps_prepa',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portionsDefautMeta = const VerificationMeta(
    'portionsDefaut',
  );
  @override
  late final GeneratedColumn<int> portionsDefaut = GeneratedColumn<int>(
    'portions_defaut',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    tempsPrepa,
    notes,
    portionsDefaut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plat';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('temps_prepa')) {
      context.handle(
        _tempsPrepaMeta,
        tempsPrepa.isAcceptableOrUnknown(data['temps_prepa']!, _tempsPrepaMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('portions_defaut')) {
      context.handle(
        _portionsDefautMeta,
        portionsDefaut.isAcceptableOrUnknown(
          data['portions_defaut']!,
          _portionsDefautMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      tempsPrepa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temps_prepa'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      portionsDefaut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}portions_defaut'],
      )!,
    );
  }

  @override
  $PlatsTable createAlias(String alias) {
    return $PlatsTable(attachedDatabase, alias);
  }
}

class Plat extends DataClass implements Insertable<Plat> {
  final int id;
  final String nom;
  final int? tempsPrepa;
  final String? notes;
  final int portionsDefaut;
  const Plat({
    required this.id,
    required this.nom,
    this.tempsPrepa,
    this.notes,
    required this.portionsDefaut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || tempsPrepa != null) {
      map['temps_prepa'] = Variable<int>(tempsPrepa);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['portions_defaut'] = Variable<int>(portionsDefaut);
    return map;
  }

  PlatsCompanion toCompanion(bool nullToAbsent) {
    return PlatsCompanion(
      id: Value(id),
      nom: Value(nom),
      tempsPrepa: tempsPrepa == null && nullToAbsent
          ? const Value.absent()
          : Value(tempsPrepa),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      portionsDefaut: Value(portionsDefaut),
    );
  }

  factory Plat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plat(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      tempsPrepa: serializer.fromJson<int?>(json['tempsPrepa']),
      notes: serializer.fromJson<String?>(json['notes']),
      portionsDefaut: serializer.fromJson<int>(json['portionsDefaut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'tempsPrepa': serializer.toJson<int?>(tempsPrepa),
      'notes': serializer.toJson<String?>(notes),
      'portionsDefaut': serializer.toJson<int>(portionsDefaut),
    };
  }

  Plat copyWith({
    int? id,
    String? nom,
    Value<int?> tempsPrepa = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? portionsDefaut,
  }) => Plat(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    tempsPrepa: tempsPrepa.present ? tempsPrepa.value : this.tempsPrepa,
    notes: notes.present ? notes.value : this.notes,
    portionsDefaut: portionsDefaut ?? this.portionsDefaut,
  );
  Plat copyWithCompanion(PlatsCompanion data) {
    return Plat(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      tempsPrepa: data.tempsPrepa.present
          ? data.tempsPrepa.value
          : this.tempsPrepa,
      notes: data.notes.present ? data.notes.value : this.notes,
      portionsDefaut: data.portionsDefaut.present
          ? data.portionsDefaut.value
          : this.portionsDefaut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plat(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('tempsPrepa: $tempsPrepa, ')
          ..write('notes: $notes, ')
          ..write('portionsDefaut: $portionsDefaut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nom, tempsPrepa, notes, portionsDefaut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plat &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.tempsPrepa == this.tempsPrepa &&
          other.notes == this.notes &&
          other.portionsDefaut == this.portionsDefaut);
}

class PlatsCompanion extends UpdateCompanion<Plat> {
  final Value<int> id;
  final Value<String> nom;
  final Value<int?> tempsPrepa;
  final Value<String?> notes;
  final Value<int> portionsDefaut;
  const PlatsCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.tempsPrepa = const Value.absent(),
    this.notes = const Value.absent(),
    this.portionsDefaut = const Value.absent(),
  });
  PlatsCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.tempsPrepa = const Value.absent(),
    this.notes = const Value.absent(),
    this.portionsDefaut = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Plat> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<int>? tempsPrepa,
    Expression<String>? notes,
    Expression<int>? portionsDefaut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (tempsPrepa != null) 'temps_prepa': tempsPrepa,
      if (notes != null) 'notes': notes,
      if (portionsDefaut != null) 'portions_defaut': portionsDefaut,
    });
  }

  PlatsCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<int?>? tempsPrepa,
    Value<String?>? notes,
    Value<int>? portionsDefaut,
  }) {
    return PlatsCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      tempsPrepa: tempsPrepa ?? this.tempsPrepa,
      notes: notes ?? this.notes,
      portionsDefaut: portionsDefaut ?? this.portionsDefaut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (tempsPrepa.present) {
      map['temps_prepa'] = Variable<int>(tempsPrepa.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (portionsDefaut.present) {
      map['portions_defaut'] = Variable<int>(portionsDefaut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatsCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('tempsPrepa: $tempsPrepa, ')
          ..write('notes: $notes, ')
          ..write('portionsDefaut: $portionsDefaut')
          ..write(')'))
        .toString();
  }
}

class $PlatIngredientsTable extends PlatIngredients
    with TableInfo<$PlatIngredientsTable, PlatIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _platIdMeta = const VerificationMeta('platId');
  @override
  late final GeneratedColumn<int> platId = GeneratedColumn<int>(
    'plat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plat (id)',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<int> produitId = GeneratedColumn<int>(
    'produit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produit (id)',
    ),
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uniteIdMeta = const VerificationMeta(
    'uniteId',
  );
  @override
  late final GeneratedColumn<int> uniteId = GeneratedColumn<int>(
    'unite_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unite (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    platId,
    produitId,
    quantite,
    uniteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plat_ingredient';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlatIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plat_id')) {
      context.handle(
        _platIdMeta,
        platId.isAcceptableOrUnknown(data['plat_id']!, _platIdMeta),
      );
    } else if (isInserting) {
      context.missing(_platIdMeta);
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_id')) {
      context.handle(
        _uniteIdMeta,
        uniteId.isAcceptableOrUnknown(data['unite_id']!, _uniteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_uniteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlatIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlatIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      platId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plat_id'],
      )!,
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produit_id'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      uniteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unite_id'],
      )!,
    );
  }

  @override
  $PlatIngredientsTable createAlias(String alias) {
    return $PlatIngredientsTable(attachedDatabase, alias);
  }
}

class PlatIngredient extends DataClass implements Insertable<PlatIngredient> {
  final int id;
  final int platId;
  final int produitId;
  final double quantite;
  final int uniteId;
  const PlatIngredient({
    required this.id,
    required this.platId,
    required this.produitId,
    required this.quantite,
    required this.uniteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plat_id'] = Variable<int>(platId);
    map['produit_id'] = Variable<int>(produitId);
    map['quantite'] = Variable<double>(quantite);
    map['unite_id'] = Variable<int>(uniteId);
    return map;
  }

  PlatIngredientsCompanion toCompanion(bool nullToAbsent) {
    return PlatIngredientsCompanion(
      id: Value(id),
      platId: Value(platId),
      produitId: Value(produitId),
      quantite: Value(quantite),
      uniteId: Value(uniteId),
    );
  }

  factory PlatIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlatIngredient(
      id: serializer.fromJson<int>(json['id']),
      platId: serializer.fromJson<int>(json['platId']),
      produitId: serializer.fromJson<int>(json['produitId']),
      quantite: serializer.fromJson<double>(json['quantite']),
      uniteId: serializer.fromJson<int>(json['uniteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'platId': serializer.toJson<int>(platId),
      'produitId': serializer.toJson<int>(produitId),
      'quantite': serializer.toJson<double>(quantite),
      'uniteId': serializer.toJson<int>(uniteId),
    };
  }

  PlatIngredient copyWith({
    int? id,
    int? platId,
    int? produitId,
    double? quantite,
    int? uniteId,
  }) => PlatIngredient(
    id: id ?? this.id,
    platId: platId ?? this.platId,
    produitId: produitId ?? this.produitId,
    quantite: quantite ?? this.quantite,
    uniteId: uniteId ?? this.uniteId,
  );
  PlatIngredient copyWithCompanion(PlatIngredientsCompanion data) {
    return PlatIngredient(
      id: data.id.present ? data.id.value : this.id,
      platId: data.platId.present ? data.platId.value : this.platId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteId: data.uniteId.present ? data.uniteId.value : this.uniteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlatIngredient(')
          ..write('id: $id, ')
          ..write('platId: $platId, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, platId, produitId, quantite, uniteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlatIngredient &&
          other.id == this.id &&
          other.platId == this.platId &&
          other.produitId == this.produitId &&
          other.quantite == this.quantite &&
          other.uniteId == this.uniteId);
}

class PlatIngredientsCompanion extends UpdateCompanion<PlatIngredient> {
  final Value<int> id;
  final Value<int> platId;
  final Value<int> produitId;
  final Value<double> quantite;
  final Value<int> uniteId;
  const PlatIngredientsCompanion({
    this.id = const Value.absent(),
    this.platId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteId = const Value.absent(),
  });
  PlatIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int platId,
    required int produitId,
    required double quantite,
    required int uniteId,
  }) : platId = Value(platId),
       produitId = Value(produitId),
       quantite = Value(quantite),
       uniteId = Value(uniteId);
  static Insertable<PlatIngredient> custom({
    Expression<int>? id,
    Expression<int>? platId,
    Expression<int>? produitId,
    Expression<double>? quantite,
    Expression<int>? uniteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platId != null) 'plat_id': platId,
      if (produitId != null) 'produit_id': produitId,
      if (quantite != null) 'quantite': quantite,
      if (uniteId != null) 'unite_id': uniteId,
    });
  }

  PlatIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? platId,
    Value<int>? produitId,
    Value<double>? quantite,
    Value<int>? uniteId,
  }) {
    return PlatIngredientsCompanion(
      id: id ?? this.id,
      platId: platId ?? this.platId,
      produitId: produitId ?? this.produitId,
      quantite: quantite ?? this.quantite,
      uniteId: uniteId ?? this.uniteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (platId.present) {
      map['plat_id'] = Variable<int>(platId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<int>(produitId.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (uniteId.present) {
      map['unite_id'] = Variable<int>(uniteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('platId: $platId, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId')
          ..write(')'))
        .toString();
  }
}

class $RepasPlanifiesTable extends RepasPlanifies
    with TableInfo<$RepasPlanifiesTable, RepasPlanifie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepasPlanifiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platIdMeta = const VerificationMeta('platId');
  @override
  late final GeneratedColumn<int> platId = GeneratedColumn<int>(
    'plat_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plat (id)',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<int> produitId = GeneratedColumn<int>(
    'produit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produit (id)',
    ),
  );
  static const VerificationMeta _portionsMeta = const VerificationMeta(
    'portions',
  );
  @override
  late final GeneratedColumn<int> portions = GeneratedColumn<int>(
    'portions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatutRepas, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(StatutRepas.planifie.name),
      ).withConverter<StatutRepas>($RepasPlanifiesTable.$converterstatut);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    platId,
    produitId,
    portions,
    statut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repas_planifie';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepasPlanifie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('plat_id')) {
      context.handle(
        _platIdMeta,
        platId.isAcceptableOrUnknown(data['plat_id']!, _platIdMeta),
      );
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    }
    if (data.containsKey('portions')) {
      context.handle(
        _portionsMeta,
        portions.isAcceptableOrUnknown(data['portions']!, _portionsMeta),
      );
    } else if (isInserting) {
      context.missing(_portionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepasPlanifie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepasPlanifie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      platId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plat_id'],
      ),
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produit_id'],
      ),
      portions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}portions'],
      )!,
      statut: $RepasPlanifiesTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
    );
  }

  @override
  $RepasPlanifiesTable createAlias(String alias) {
    return $RepasPlanifiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatutRepas, String, String> $converterstatut =
      const EnumNameConverter<StatutRepas>(StatutRepas.values);
}

class RepasPlanifie extends DataClass implements Insertable<RepasPlanifie> {
  final int id;
  final DateTime date;
  final int? platId;

  /// Alternative à `platId` si le repas planifié est un produit isolé, sans
  /// plat associé (cf. documentation-technique.md §2 "RepasPlanifie").
  final int? produitId;
  final int portions;
  final StatutRepas statut;
  const RepasPlanifie({
    required this.id,
    required this.date,
    this.platId,
    this.produitId,
    required this.portions,
    required this.statut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || platId != null) {
      map['plat_id'] = Variable<int>(platId);
    }
    if (!nullToAbsent || produitId != null) {
      map['produit_id'] = Variable<int>(produitId);
    }
    map['portions'] = Variable<int>(portions);
    {
      map['statut'] = Variable<String>(
        $RepasPlanifiesTable.$converterstatut.toSql(statut),
      );
    }
    return map;
  }

  RepasPlanifiesCompanion toCompanion(bool nullToAbsent) {
    return RepasPlanifiesCompanion(
      id: Value(id),
      date: Value(date),
      platId: platId == null && nullToAbsent
          ? const Value.absent()
          : Value(platId),
      produitId: produitId == null && nullToAbsent
          ? const Value.absent()
          : Value(produitId),
      portions: Value(portions),
      statut: Value(statut),
    );
  }

  factory RepasPlanifie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepasPlanifie(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      platId: serializer.fromJson<int?>(json['platId']),
      produitId: serializer.fromJson<int?>(json['produitId']),
      portions: serializer.fromJson<int>(json['portions']),
      statut: $RepasPlanifiesTable.$converterstatut.fromJson(
        serializer.fromJson<String>(json['statut']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'platId': serializer.toJson<int?>(platId),
      'produitId': serializer.toJson<int?>(produitId),
      'portions': serializer.toJson<int>(portions),
      'statut': serializer.toJson<String>(
        $RepasPlanifiesTable.$converterstatut.toJson(statut),
      ),
    };
  }

  RepasPlanifie copyWith({
    int? id,
    DateTime? date,
    Value<int?> platId = const Value.absent(),
    Value<int?> produitId = const Value.absent(),
    int? portions,
    StatutRepas? statut,
  }) => RepasPlanifie(
    id: id ?? this.id,
    date: date ?? this.date,
    platId: platId.present ? platId.value : this.platId,
    produitId: produitId.present ? produitId.value : this.produitId,
    portions: portions ?? this.portions,
    statut: statut ?? this.statut,
  );
  RepasPlanifie copyWithCompanion(RepasPlanifiesCompanion data) {
    return RepasPlanifie(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      platId: data.platId.present ? data.platId.value : this.platId,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      portions: data.portions.present ? data.portions.value : this.portions,
      statut: data.statut.present ? data.statut.value : this.statut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepasPlanifie(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('platId: $platId, ')
          ..write('produitId: $produitId, ')
          ..write('portions: $portions, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, platId, produitId, portions, statut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepasPlanifie &&
          other.id == this.id &&
          other.date == this.date &&
          other.platId == this.platId &&
          other.produitId == this.produitId &&
          other.portions == this.portions &&
          other.statut == this.statut);
}

class RepasPlanifiesCompanion extends UpdateCompanion<RepasPlanifie> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int?> platId;
  final Value<int?> produitId;
  final Value<int> portions;
  final Value<StatutRepas> statut;
  const RepasPlanifiesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.platId = const Value.absent(),
    this.produitId = const Value.absent(),
    this.portions = const Value.absent(),
    this.statut = const Value.absent(),
  });
  RepasPlanifiesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    this.platId = const Value.absent(),
    this.produitId = const Value.absent(),
    required int portions,
    this.statut = const Value.absent(),
  }) : date = Value(date),
       portions = Value(portions);
  static Insertable<RepasPlanifie> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? platId,
    Expression<int>? produitId,
    Expression<int>? portions,
    Expression<String>? statut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (platId != null) 'plat_id': platId,
      if (produitId != null) 'produit_id': produitId,
      if (portions != null) 'portions': portions,
      if (statut != null) 'statut': statut,
    });
  }

  RepasPlanifiesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int?>? platId,
    Value<int?>? produitId,
    Value<int>? portions,
    Value<StatutRepas>? statut,
  }) {
    return RepasPlanifiesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      platId: platId ?? this.platId,
      produitId: produitId ?? this.produitId,
      portions: portions ?? this.portions,
      statut: statut ?? this.statut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (platId.present) {
      map['plat_id'] = Variable<int>(platId.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<int>(produitId.value);
    }
    if (portions.present) {
      map['portions'] = Variable<int>(portions.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $RepasPlanifiesTable.$converterstatut.toSql(statut.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepasPlanifiesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('platId: $platId, ')
          ..write('produitId: $produitId, ')
          ..write('portions: $portions, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }
}

class $ArticlesCourseTable extends ArticlesCourse
    with TableInfo<$ArticlesCourseTable, ArticleCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesCourseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _produitIdMeta = const VerificationMeta(
    'produitId',
  );
  @override
  late final GeneratedColumn<int> produitId = GeneratedColumn<int>(
    'produit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produit (id)',
    ),
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uniteIdMeta = const VerificationMeta(
    'uniteId',
  );
  @override
  late final GeneratedColumn<int> uniteId = GeneratedColumn<int>(
    'unite_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unite (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<OrigineArticle, String> origine =
      GeneratedColumn<String>(
        'origine',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(OrigineArticle.manuel.name),
      ).withConverter<OrigineArticle>($ArticlesCourseTable.$converterorigine);
  @override
  late final GeneratedColumnWithTypeConverter<StatutArticle, String> statut =
      GeneratedColumn<String>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(StatutArticle.aAcheter.name),
      ).withConverter<StatutArticle>($ArticlesCourseTable.$converterstatut);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    produitId,
    quantite,
    uniteId,
    origine,
    statut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_course';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArticleCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('produit_id')) {
      context.handle(
        _produitIdMeta,
        produitId.isAcceptableOrUnknown(data['produit_id']!, _produitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produitIdMeta);
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    } else if (isInserting) {
      context.missing(_quantiteMeta);
    }
    if (data.containsKey('unite_id')) {
      context.handle(
        _uniteIdMeta,
        uniteId.isAcceptableOrUnknown(data['unite_id']!, _uniteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_uniteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArticleCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleCourse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      produitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produit_id'],
      )!,
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      uniteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unite_id'],
      )!,
      origine: $ArticlesCourseTable.$converterorigine.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origine'],
        )!,
      ),
      statut: $ArticlesCourseTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}statut'],
        )!,
      ),
    );
  }

  @override
  $ArticlesCourseTable createAlias(String alias) {
    return $ArticlesCourseTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OrigineArticle, String, String> $converterorigine =
      const EnumNameConverter<OrigineArticle>(OrigineArticle.values);
  static JsonTypeConverter2<StatutArticle, String, String> $converterstatut =
      const EnumNameConverter<StatutArticle>(StatutArticle.values);
}

class ArticleCourse extends DataClass implements Insertable<ArticleCourse> {
  final int id;
  final int produitId;
  final double quantite;
  final int uniteId;
  final OrigineArticle origine;
  final StatutArticle statut;
  const ArticleCourse({
    required this.id,
    required this.produitId,
    required this.quantite,
    required this.uniteId,
    required this.origine,
    required this.statut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['produit_id'] = Variable<int>(produitId);
    map['quantite'] = Variable<double>(quantite);
    map['unite_id'] = Variable<int>(uniteId);
    {
      map['origine'] = Variable<String>(
        $ArticlesCourseTable.$converterorigine.toSql(origine),
      );
    }
    {
      map['statut'] = Variable<String>(
        $ArticlesCourseTable.$converterstatut.toSql(statut),
      );
    }
    return map;
  }

  ArticlesCourseCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCourseCompanion(
      id: Value(id),
      produitId: Value(produitId),
      quantite: Value(quantite),
      uniteId: Value(uniteId),
      origine: Value(origine),
      statut: Value(statut),
    );
  }

  factory ArticleCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleCourse(
      id: serializer.fromJson<int>(json['id']),
      produitId: serializer.fromJson<int>(json['produitId']),
      quantite: serializer.fromJson<double>(json['quantite']),
      uniteId: serializer.fromJson<int>(json['uniteId']),
      origine: $ArticlesCourseTable.$converterorigine.fromJson(
        serializer.fromJson<String>(json['origine']),
      ),
      statut: $ArticlesCourseTable.$converterstatut.fromJson(
        serializer.fromJson<String>(json['statut']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'produitId': serializer.toJson<int>(produitId),
      'quantite': serializer.toJson<double>(quantite),
      'uniteId': serializer.toJson<int>(uniteId),
      'origine': serializer.toJson<String>(
        $ArticlesCourseTable.$converterorigine.toJson(origine),
      ),
      'statut': serializer.toJson<String>(
        $ArticlesCourseTable.$converterstatut.toJson(statut),
      ),
    };
  }

  ArticleCourse copyWith({
    int? id,
    int? produitId,
    double? quantite,
    int? uniteId,
    OrigineArticle? origine,
    StatutArticle? statut,
  }) => ArticleCourse(
    id: id ?? this.id,
    produitId: produitId ?? this.produitId,
    quantite: quantite ?? this.quantite,
    uniteId: uniteId ?? this.uniteId,
    origine: origine ?? this.origine,
    statut: statut ?? this.statut,
  );
  ArticleCourse copyWithCompanion(ArticlesCourseCompanion data) {
    return ArticleCourse(
      id: data.id.present ? data.id.value : this.id,
      produitId: data.produitId.present ? data.produitId.value : this.produitId,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      uniteId: data.uniteId.present ? data.uniteId.value : this.uniteId,
      origine: data.origine.present ? data.origine.value : this.origine,
      statut: data.statut.present ? data.statut.value : this.statut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleCourse(')
          ..write('id: $id, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId, ')
          ..write('origine: $origine, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, produitId, quantite, uniteId, origine, statut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleCourse &&
          other.id == this.id &&
          other.produitId == this.produitId &&
          other.quantite == this.quantite &&
          other.uniteId == this.uniteId &&
          other.origine == this.origine &&
          other.statut == this.statut);
}

class ArticlesCourseCompanion extends UpdateCompanion<ArticleCourse> {
  final Value<int> id;
  final Value<int> produitId;
  final Value<double> quantite;
  final Value<int> uniteId;
  final Value<OrigineArticle> origine;
  final Value<StatutArticle> statut;
  const ArticlesCourseCompanion({
    this.id = const Value.absent(),
    this.produitId = const Value.absent(),
    this.quantite = const Value.absent(),
    this.uniteId = const Value.absent(),
    this.origine = const Value.absent(),
    this.statut = const Value.absent(),
  });
  ArticlesCourseCompanion.insert({
    this.id = const Value.absent(),
    required int produitId,
    required double quantite,
    required int uniteId,
    this.origine = const Value.absent(),
    this.statut = const Value.absent(),
  }) : produitId = Value(produitId),
       quantite = Value(quantite),
       uniteId = Value(uniteId);
  static Insertable<ArticleCourse> custom({
    Expression<int>? id,
    Expression<int>? produitId,
    Expression<double>? quantite,
    Expression<int>? uniteId,
    Expression<String>? origine,
    Expression<String>? statut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (produitId != null) 'produit_id': produitId,
      if (quantite != null) 'quantite': quantite,
      if (uniteId != null) 'unite_id': uniteId,
      if (origine != null) 'origine': origine,
      if (statut != null) 'statut': statut,
    });
  }

  ArticlesCourseCompanion copyWith({
    Value<int>? id,
    Value<int>? produitId,
    Value<double>? quantite,
    Value<int>? uniteId,
    Value<OrigineArticle>? origine,
    Value<StatutArticle>? statut,
  }) {
    return ArticlesCourseCompanion(
      id: id ?? this.id,
      produitId: produitId ?? this.produitId,
      quantite: quantite ?? this.quantite,
      uniteId: uniteId ?? this.uniteId,
      origine: origine ?? this.origine,
      statut: statut ?? this.statut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (produitId.present) {
      map['produit_id'] = Variable<int>(produitId.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (uniteId.present) {
      map['unite_id'] = Variable<int>(uniteId.value);
    }
    if (origine.present) {
      map['origine'] = Variable<String>(
        $ArticlesCourseTable.$converterorigine.toSql(origine.value),
      );
    }
    if (statut.present) {
      map['statut'] = Variable<String>(
        $ArticlesCourseTable.$converterstatut.toSql(statut.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCourseCompanion(')
          ..write('id: $id, ')
          ..write('produitId: $produitId, ')
          ..write('quantite: $quantite, ')
          ..write('uniteId: $uniteId, ')
          ..write('origine: $origine, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }
}

class $ReglagesTable extends Reglages with TableInfo<$ReglagesTable, Reglage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReglagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cleMeta = const VerificationMeta('cle');
  @override
  late final GeneratedColumn<String> cle = GeneratedColumn<String>(
    'cle',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
    'valeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cle, valeur];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reglage';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reglage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cle')) {
      context.handle(
        _cleMeta,
        cle.isAcceptableOrUnknown(data['cle']!, _cleMeta),
      );
    } else if (isInserting) {
      context.missing(_cleMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(
        _valeurMeta,
        valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta),
      );
    } else if (isInserting) {
      context.missing(_valeurMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cle};
  @override
  Reglage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reglage(
      cle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cle'],
      )!,
      valeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valeur'],
      )!,
    );
  }

  @override
  $ReglagesTable createAlias(String alias) {
    return $ReglagesTable(attachedDatabase, alias);
  }
}

class Reglage extends DataClass implements Insertable<Reglage> {
  final String cle;
  final String valeur;
  const Reglage({required this.cle, required this.valeur});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cle'] = Variable<String>(cle);
    map['valeur'] = Variable<String>(valeur);
    return map;
  }

  ReglagesCompanion toCompanion(bool nullToAbsent) {
    return ReglagesCompanion(cle: Value(cle), valeur: Value(valeur));
  }

  factory Reglage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reglage(
      cle: serializer.fromJson<String>(json['cle']),
      valeur: serializer.fromJson<String>(json['valeur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cle': serializer.toJson<String>(cle),
      'valeur': serializer.toJson<String>(valeur),
    };
  }

  Reglage copyWith({String? cle, String? valeur}) =>
      Reglage(cle: cle ?? this.cle, valeur: valeur ?? this.valeur);
  Reglage copyWithCompanion(ReglagesCompanion data) {
    return Reglage(
      cle: data.cle.present ? data.cle.value : this.cle,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reglage(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cle, valeur);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reglage &&
          other.cle == this.cle &&
          other.valeur == this.valeur);
}

class ReglagesCompanion extends UpdateCompanion<Reglage> {
  final Value<String> cle;
  final Value<String> valeur;
  final Value<int> rowid;
  const ReglagesCompanion({
    this.cle = const Value.absent(),
    this.valeur = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReglagesCompanion.insert({
    required String cle,
    required String valeur,
    this.rowid = const Value.absent(),
  }) : cle = Value(cle),
       valeur = Value(valeur);
  static Insertable<Reglage> custom({
    Expression<String>? cle,
    Expression<String>? valeur,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cle != null) 'cle': cle,
      if (valeur != null) 'valeur': valeur,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReglagesCompanion copyWith({
    Value<String>? cle,
    Value<String>? valeur,
    Value<int>? rowid,
  }) {
    return ReglagesCompanion(
      cle: cle ?? this.cle,
      valeur: valeur ?? this.valeur,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cle.present) {
      map['cle'] = Variable<String>(cle.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReglagesCompanion(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ZonesTable zones = $ZonesTable(this);
  late final $UnitesTable unites = $UnitesTable(this);
  late final $ProduitsTable produits = $ProduitsTable(this);
  late final $ProduitsFrigoTable produitsFrigo = $ProduitsFrigoTable(this);
  late final $PlatsTable plats = $PlatsTable(this);
  late final $PlatIngredientsTable platIngredients = $PlatIngredientsTable(
    this,
  );
  late final $RepasPlanifiesTable repasPlanifies = $RepasPlanifiesTable(this);
  late final $ArticlesCourseTable articlesCourse = $ArticlesCourseTable(this);
  late final $ReglagesTable reglages = $ReglagesTable(this);
  late final Index uxProduitCodeBarre = Index(
    'ux_produit_code_barre',
    'CREATE UNIQUE INDEX ux_produit_code_barre ON produit (code_barre)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    zones,
    unites,
    produits,
    produitsFrigo,
    plats,
    platIngredients,
    repasPlanifies,
    articlesCourse,
    reglages,
    uxProduitCodeBarre,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String nom,
      Value<String> icone,
      Value<bool> estParDefaut,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<String> icone,
      Value<bool> estParDefaut,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Categorie> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProduitsTable, List<Produit>> _produitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.produits,
    aliasName: 'categorie__id__produit__categorie_id',
  );

  $$ProduitsTableProcessedTableManager get produitsRefs {
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.categorieId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estParDefaut => $composableBuilder(
    column: $table.estParDefaut,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produitsRefs(
    Expression<bool> Function($$ProduitsTableFilterComposer f) f,
  ) {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estParDefaut => $composableBuilder(
    column: $table.estParDefaut,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get icone =>
      $composableBuilder(column: $table.icone, builder: (column) => column);

  GeneratedColumn<bool> get estParDefaut => $composableBuilder(
    column: $table.estParDefaut,
    builder: (column) => column,
  );

  Expression<T> produitsRefs<T extends Object>(
    Expression<T> Function($$ProduitsTableAnnotationComposer a) f,
  ) {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.categorieId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Categorie,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Categorie, $$CategoriesTableReferences),
          Categorie,
          PrefetchHooks Function({bool produitsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> icone = const Value.absent(),
                Value<bool> estParDefaut = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                nom: nom,
                icone: icone,
                estParDefaut: estParDefaut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                Value<String> icone = const Value.absent(),
                Value<bool> estParDefaut = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                nom: nom,
                icone: icone,
                estParDefaut: estParDefaut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (produitsRefs) db.produits],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produitsRefs)
                    await $_getPrefetchedData<
                      Categorie,
                      $CategoriesTable,
                      Produit
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._produitsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).produitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categorieId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Categorie,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Categorie, $$CategoriesTableReferences),
      Categorie,
      PrefetchHooks Function({bool produitsRefs})
    >;
typedef $$ZonesTableCreateCompanionBuilder =
    ZonesCompanion Function({
      Value<int> id,
      required String nom,
      Value<String> icone,
      Value<bool> isRoot,
    });
typedef $$ZonesTableUpdateCompanionBuilder =
    ZonesCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<String> icone,
      Value<bool> isRoot,
    });

final class $$ZonesTableReferences
    extends BaseReferences<_$AppDatabase, $ZonesTable, Zone> {
  $$ZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProduitsFrigoTable, List<ProduitFrigo>>
  _produitsFrigoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.produitsFrigo,
    aliasName: 'zone__id__produit_frigo__zone_id',
  );

  $$ProduitsFrigoTableProcessedTableManager get produitsFrigoRefs {
    final manager = $$ProduitsFrigoTableTableManager(
      $_db,
      $_db.produitsFrigo,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsFrigoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ZonesTableFilterComposer extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRoot => $composableBuilder(
    column: $table.isRoot,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produitsFrigoRefs(
    Expression<bool> Function($$ProduitsFrigoTableFilterComposer f) f,
  ) {
    final $$ProduitsFrigoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableFilterComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icone => $composableBuilder(
    column: $table.icone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRoot => $composableBuilder(
    column: $table.isRoot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZonesTable> {
  $$ZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get icone =>
      $composableBuilder(column: $table.icone, builder: (column) => column);

  GeneratedColumn<bool> get isRoot =>
      $composableBuilder(column: $table.isRoot, builder: (column) => column);

  Expression<T> produitsFrigoRefs<T extends Object>(
    Expression<T> Function($$ProduitsFrigoTableAnnotationComposer a) f,
  ) {
    final $$ProduitsFrigoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.zoneId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableAnnotationComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZonesTable,
          Zone,
          $$ZonesTableFilterComposer,
          $$ZonesTableOrderingComposer,
          $$ZonesTableAnnotationComposer,
          $$ZonesTableCreateCompanionBuilder,
          $$ZonesTableUpdateCompanionBuilder,
          (Zone, $$ZonesTableReferences),
          Zone,
          PrefetchHooks Function({bool produitsFrigoRefs})
        > {
  $$ZonesTableTableManager(_$AppDatabase db, $ZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<String> icone = const Value.absent(),
                Value<bool> isRoot = const Value.absent(),
              }) => ZonesCompanion(
                id: id,
                nom: nom,
                icone: icone,
                isRoot: isRoot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                Value<String> icone = const Value.absent(),
                Value<bool> isRoot = const Value.absent(),
              }) => ZonesCompanion.insert(
                id: id,
                nom: nom,
                icone: icone,
                isRoot: isRoot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ZonesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({produitsFrigoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (produitsFrigoRefs) db.produitsFrigo,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produitsFrigoRefs)
                    await $_getPrefetchedData<Zone, $ZonesTable, ProduitFrigo>(
                      currentTable: table,
                      referencedTable: $$ZonesTableReferences
                          ._produitsFrigoRefsTable(db),
                      managerFromTypedResult: (p0) => $$ZonesTableReferences(
                        db,
                        table,
                        p0,
                      ).produitsFrigoRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.zoneId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZonesTable,
      Zone,
      $$ZonesTableFilterComposer,
      $$ZonesTableOrderingComposer,
      $$ZonesTableAnnotationComposer,
      $$ZonesTableCreateCompanionBuilder,
      $$ZonesTableUpdateCompanionBuilder,
      (Zone, $$ZonesTableReferences),
      Zone,
      PrefetchHooks Function({bool produitsFrigoRefs})
    >;
typedef $$UnitesTableCreateCompanionBuilder =
    UnitesCompanion Function({
      Value<int> id,
      required String nom,
      required TypeGrandeur typeGrandeur,
      required double facteurVersBase,
    });
typedef $$UnitesTableUpdateCompanionBuilder =
    UnitesCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<TypeGrandeur> typeGrandeur,
      Value<double> facteurVersBase,
    });

final class $$UnitesTableReferences
    extends BaseReferences<_$AppDatabase, $UnitesTable, Unite> {
  $$UnitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProduitsTable, List<Produit>> _produitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.produits,
    aliasName: 'unite__id__produit__unite_defaut_id',
  );

  $$ProduitsTableProcessedTableManager get produitsRefs {
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.uniteDefautId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProduitsFrigoTable, List<ProduitFrigo>>
  _produitsFrigoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.produitsFrigo,
    aliasName: 'unite__id__produit_frigo__unite_id',
  );

  $$ProduitsFrigoTableProcessedTableManager get produitsFrigoRefs {
    final manager = $$ProduitsFrigoTableTableManager(
      $_db,
      $_db.produitsFrigo,
    ).filter((f) => f.uniteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsFrigoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlatIngredientsTable, List<PlatIngredient>>
  _platIngredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.platIngredients,
    aliasName: 'unite__id__plat_ingredient__unite_id',
  );

  $$PlatIngredientsTableProcessedTableManager get platIngredientsRefs {
    final manager = $$PlatIngredientsTableTableManager(
      $_db,
      $_db.platIngredients,
    ).filter((f) => f.uniteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _platIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ArticlesCourseTable, List<ArticleCourse>>
  _articlesCourseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articlesCourse,
    aliasName: 'unite__id__article_course__unite_id',
  );

  $$ArticlesCourseTableProcessedTableManager get articlesCourseRefs {
    final manager = $$ArticlesCourseTableTableManager(
      $_db,
      $_db.articlesCourse,
    ).filter((f) => f.uniteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articlesCourseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnitesTableFilterComposer
    extends Composer<_$AppDatabase, $UnitesTable> {
  $$UnitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TypeGrandeur, TypeGrandeur, String>
  get typeGrandeur => $composableBuilder(
    column: $table.typeGrandeur,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get facteurVersBase => $composableBuilder(
    column: $table.facteurVersBase,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produitsRefs(
    Expression<bool> Function($$ProduitsTableFilterComposer f) f,
  ) {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.uniteDefautId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> produitsFrigoRefs(
    Expression<bool> Function($$ProduitsFrigoTableFilterComposer f) f,
  ) {
    final $$ProduitsFrigoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableFilterComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> platIngredientsRefs(
    Expression<bool> Function($$PlatIngredientsTableFilterComposer f) f,
  ) {
    final $$PlatIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> articlesCourseRefs(
    Expression<bool> Function($$ArticlesCourseTableFilterComposer f) f,
  ) {
    final $$ArticlesCourseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articlesCourse,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesCourseTableFilterComposer(
            $db: $db,
            $table: $db.articlesCourse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitesTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitesTable> {
  $$UnitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeGrandeur => $composableBuilder(
    column: $table.typeGrandeur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get facteurVersBase => $composableBuilder(
    column: $table.facteurVersBase,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitesTable> {
  $$UnitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TypeGrandeur, String> get typeGrandeur =>
      $composableBuilder(
        column: $table.typeGrandeur,
        builder: (column) => column,
      );

  GeneratedColumn<double> get facteurVersBase => $composableBuilder(
    column: $table.facteurVersBase,
    builder: (column) => column,
  );

  Expression<T> produitsRefs<T extends Object>(
    Expression<T> Function($$ProduitsTableAnnotationComposer a) f,
  ) {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.uniteDefautId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> produitsFrigoRefs<T extends Object>(
    Expression<T> Function($$ProduitsFrigoTableAnnotationComposer a) f,
  ) {
    final $$ProduitsFrigoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableAnnotationComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> platIngredientsRefs<T extends Object>(
    Expression<T> Function($$PlatIngredientsTableAnnotationComposer a) f,
  ) {
    final $$PlatIngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> articlesCourseRefs<T extends Object>(
    Expression<T> Function($$ArticlesCourseTableAnnotationComposer a) f,
  ) {
    final $$ArticlesCourseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articlesCourse,
      getReferencedColumn: (t) => t.uniteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesCourseTableAnnotationComposer(
            $db: $db,
            $table: $db.articlesCourse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitesTable,
          Unite,
          $$UnitesTableFilterComposer,
          $$UnitesTableOrderingComposer,
          $$UnitesTableAnnotationComposer,
          $$UnitesTableCreateCompanionBuilder,
          $$UnitesTableUpdateCompanionBuilder,
          (Unite, $$UnitesTableReferences),
          Unite,
          PrefetchHooks Function({
            bool produitsRefs,
            bool produitsFrigoRefs,
            bool platIngredientsRefs,
            bool articlesCourseRefs,
          })
        > {
  $$UnitesTableTableManager(_$AppDatabase db, $UnitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<TypeGrandeur> typeGrandeur = const Value.absent(),
                Value<double> facteurVersBase = const Value.absent(),
              }) => UnitesCompanion(
                id: id,
                nom: nom,
                typeGrandeur: typeGrandeur,
                facteurVersBase: facteurVersBase,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                required TypeGrandeur typeGrandeur,
                required double facteurVersBase,
              }) => UnitesCompanion.insert(
                id: id,
                nom: nom,
                typeGrandeur: typeGrandeur,
                facteurVersBase: facteurVersBase,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UnitesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                produitsRefs = false,
                produitsFrigoRefs = false,
                platIngredientsRefs = false,
                articlesCourseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (produitsRefs) db.produits,
                    if (produitsFrigoRefs) db.produitsFrigo,
                    if (platIngredientsRefs) db.platIngredients,
                    if (articlesCourseRefs) db.articlesCourse,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (produitsRefs)
                        await $_getPrefetchedData<Unite, $UnitesTable, Produit>(
                          currentTable: table,
                          referencedTable: $$UnitesTableReferences
                              ._produitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitesTableReferences(
                                db,
                                table,
                                p0,
                              ).produitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.uniteDefautId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (produitsFrigoRefs)
                        await $_getPrefetchedData<
                          Unite,
                          $UnitesTable,
                          ProduitFrigo
                        >(
                          currentTable: table,
                          referencedTable: $$UnitesTableReferences
                              ._produitsFrigoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitesTableReferences(
                                db,
                                table,
                                p0,
                              ).produitsFrigoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.uniteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (platIngredientsRefs)
                        await $_getPrefetchedData<
                          Unite,
                          $UnitesTable,
                          PlatIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$UnitesTableReferences
                              ._platIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitesTableReferences(
                                db,
                                table,
                                p0,
                              ).platIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.uniteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (articlesCourseRefs)
                        await $_getPrefetchedData<
                          Unite,
                          $UnitesTable,
                          ArticleCourse
                        >(
                          currentTable: table,
                          referencedTable: $$UnitesTableReferences
                              ._articlesCourseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UnitesTableReferences(
                                db,
                                table,
                                p0,
                              ).articlesCourseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.uniteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UnitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitesTable,
      Unite,
      $$UnitesTableFilterComposer,
      $$UnitesTableOrderingComposer,
      $$UnitesTableAnnotationComposer,
      $$UnitesTableCreateCompanionBuilder,
      $$UnitesTableUpdateCompanionBuilder,
      (Unite, $$UnitesTableReferences),
      Unite,
      PrefetchHooks Function({
        bool produitsRefs,
        bool produitsFrigoRefs,
        bool platIngredientsRefs,
        bool articlesCourseRefs,
      })
    >;
typedef $$ProduitsTableCreateCompanionBuilder =
    ProduitsCompanion Function({
      Value<int> id,
      required String nom,
      required int categorieId,
      required TypeGrandeur typeGrandeur,
      required int uniteDefautId,
      Value<StatutProduit> statut,
      Value<DateTime?> dateDerniereUtilisation,
      Value<String?> codeBarre,
    });
typedef $$ProduitsTableUpdateCompanionBuilder =
    ProduitsCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<int> categorieId,
      Value<TypeGrandeur> typeGrandeur,
      Value<int> uniteDefautId,
      Value<StatutProduit> statut,
      Value<DateTime?> dateDerniereUtilisation,
      Value<String?> codeBarre,
    });

final class $$ProduitsTableReferences
    extends BaseReferences<_$AppDatabase, $ProduitsTable, Produit> {
  $$ProduitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categorieIdTable(_$AppDatabase db) =>
      db.categories.createAlias('produit__categorie_id__categorie__id');

  $$CategoriesTableProcessedTableManager get categorieId {
    final $_column = $_itemColumn<int>('categorie_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categorieIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitesTable _uniteDefautIdTable(_$AppDatabase db) =>
      db.unites.createAlias('produit__unite_defaut_id__unite__id');

  $$UnitesTableProcessedTableManager get uniteDefautId {
    final $_column = $_itemColumn<int>('unite_defaut_id')!;

    final manager = $$UnitesTableTableManager(
      $_db,
      $_db.unites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uniteDefautIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProduitsFrigoTable, List<ProduitFrigo>>
  _produitsFrigoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.produitsFrigo,
    aliasName: 'produit__id__produit_frigo__produit_id',
  );

  $$ProduitsFrigoTableProcessedTableManager get produitsFrigoRefs {
    final manager = $$ProduitsFrigoTableTableManager(
      $_db,
      $_db.produitsFrigo,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produitsFrigoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlatIngredientsTable, List<PlatIngredient>>
  _platIngredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.platIngredients,
    aliasName: 'produit__id__plat_ingredient__produit_id',
  );

  $$PlatIngredientsTableProcessedTableManager get platIngredientsRefs {
    final manager = $$PlatIngredientsTableTableManager(
      $_db,
      $_db.platIngredients,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _platIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepasPlanifiesTable, List<RepasPlanifie>>
  _repasPlanifiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repasPlanifies,
    aliasName: 'produit__id__repas_planifie__produit_id',
  );

  $$RepasPlanifiesTableProcessedTableManager get repasPlanifiesRefs {
    final manager = $$RepasPlanifiesTableTableManager(
      $_db,
      $_db.repasPlanifies,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repasPlanifiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ArticlesCourseTable, List<ArticleCourse>>
  _articlesCourseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.articlesCourse,
    aliasName: 'produit__id__article_course__produit_id',
  );

  $$ArticlesCourseTableProcessedTableManager get articlesCourseRefs {
    final manager = $$ArticlesCourseTableTableManager(
      $_db,
      $_db.articlesCourse,
    ).filter((f) => f.produitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articlesCourseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProduitsTableFilterComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TypeGrandeur, TypeGrandeur, String>
  get typeGrandeur => $composableBuilder(
    column: $table.typeGrandeur,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<StatutProduit, StatutProduit, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dateDerniereUtilisation => $composableBuilder(
    column: $table.dateDerniereUtilisation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeBarre => $composableBuilder(
    column: $table.codeBarre,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categorieId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableFilterComposer get uniteDefautId {
    final $$UnitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteDefautId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableFilterComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> produitsFrigoRefs(
    Expression<bool> Function($$ProduitsFrigoTableFilterComposer f) f,
  ) {
    final $$ProduitsFrigoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableFilterComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> platIngredientsRefs(
    Expression<bool> Function($$PlatIngredientsTableFilterComposer f) f,
  ) {
    final $$PlatIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repasPlanifiesRefs(
    Expression<bool> Function($$RepasPlanifiesTableFilterComposer f) f,
  ) {
    final $$RepasPlanifiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repasPlanifies,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepasPlanifiesTableFilterComposer(
            $db: $db,
            $table: $db.repasPlanifies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> articlesCourseRefs(
    Expression<bool> Function($$ArticlesCourseTableFilterComposer f) f,
  ) {
    final $$ArticlesCourseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articlesCourse,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesCourseTableFilterComposer(
            $db: $db,
            $table: $db.articlesCourse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeGrandeur => $composableBuilder(
    column: $table.typeGrandeur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDerniereUtilisation => $composableBuilder(
    column: $table.dateDerniereUtilisation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeBarre => $composableBuilder(
    column: $table.codeBarre,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categorieId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableOrderingComposer get uniteDefautId {
    final $$UnitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteDefautId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableOrderingComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProduitsTable> {
  $$ProduitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TypeGrandeur, String> get typeGrandeur =>
      $composableBuilder(
        column: $table.typeGrandeur,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<StatutProduit, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateDerniereUtilisation => $composableBuilder(
    column: $table.dateDerniereUtilisation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codeBarre =>
      $composableBuilder(column: $table.codeBarre, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categorieId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categorieId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableAnnotationComposer get uniteDefautId {
    final $$UnitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteDefautId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableAnnotationComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> produitsFrigoRefs<T extends Object>(
    Expression<T> Function($$ProduitsFrigoTableAnnotationComposer a) f,
  ) {
    final $$ProduitsFrigoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produitsFrigo,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsFrigoTableAnnotationComposer(
            $db: $db,
            $table: $db.produitsFrigo,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> platIngredientsRefs<T extends Object>(
    Expression<T> Function($$PlatIngredientsTableAnnotationComposer a) f,
  ) {
    final $$PlatIngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> repasPlanifiesRefs<T extends Object>(
    Expression<T> Function($$RepasPlanifiesTableAnnotationComposer a) f,
  ) {
    final $$RepasPlanifiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repasPlanifies,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepasPlanifiesTableAnnotationComposer(
            $db: $db,
            $table: $db.repasPlanifies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> articlesCourseRefs<T extends Object>(
    Expression<T> Function($$ArticlesCourseTableAnnotationComposer a) f,
  ) {
    final $$ArticlesCourseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articlesCourse,
      getReferencedColumn: (t) => t.produitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesCourseTableAnnotationComposer(
            $db: $db,
            $table: $db.articlesCourse,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProduitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProduitsTable,
          Produit,
          $$ProduitsTableFilterComposer,
          $$ProduitsTableOrderingComposer,
          $$ProduitsTableAnnotationComposer,
          $$ProduitsTableCreateCompanionBuilder,
          $$ProduitsTableUpdateCompanionBuilder,
          (Produit, $$ProduitsTableReferences),
          Produit,
          PrefetchHooks Function({
            bool categorieId,
            bool uniteDefautId,
            bool produitsFrigoRefs,
            bool platIngredientsRefs,
            bool repasPlanifiesRefs,
            bool articlesCourseRefs,
          })
        > {
  $$ProduitsTableTableManager(_$AppDatabase db, $ProduitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProduitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> categorieId = const Value.absent(),
                Value<TypeGrandeur> typeGrandeur = const Value.absent(),
                Value<int> uniteDefautId = const Value.absent(),
                Value<StatutProduit> statut = const Value.absent(),
                Value<DateTime?> dateDerniereUtilisation = const Value.absent(),
                Value<String?> codeBarre = const Value.absent(),
              }) => ProduitsCompanion(
                id: id,
                nom: nom,
                categorieId: categorieId,
                typeGrandeur: typeGrandeur,
                uniteDefautId: uniteDefautId,
                statut: statut,
                dateDerniereUtilisation: dateDerniereUtilisation,
                codeBarre: codeBarre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                required int categorieId,
                required TypeGrandeur typeGrandeur,
                required int uniteDefautId,
                Value<StatutProduit> statut = const Value.absent(),
                Value<DateTime?> dateDerniereUtilisation = const Value.absent(),
                Value<String?> codeBarre = const Value.absent(),
              }) => ProduitsCompanion.insert(
                id: id,
                nom: nom,
                categorieId: categorieId,
                typeGrandeur: typeGrandeur,
                uniteDefautId: uniteDefautId,
                statut: statut,
                dateDerniereUtilisation: dateDerniereUtilisation,
                codeBarre: codeBarre,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProduitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categorieId = false,
                uniteDefautId = false,
                produitsFrigoRefs = false,
                platIngredientsRefs = false,
                repasPlanifiesRefs = false,
                articlesCourseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (produitsFrigoRefs) db.produitsFrigo,
                    if (platIngredientsRefs) db.platIngredients,
                    if (repasPlanifiesRefs) db.repasPlanifies,
                    if (articlesCourseRefs) db.articlesCourse,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categorieId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categorieId,
                                    referencedTable: $$ProduitsTableReferences
                                        ._categorieIdTable(db),
                                    referencedColumn: $$ProduitsTableReferences
                                        ._categorieIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (uniteDefautId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.uniteDefautId,
                                    referencedTable: $$ProduitsTableReferences
                                        ._uniteDefautIdTable(db),
                                    referencedColumn: $$ProduitsTableReferences
                                        ._uniteDefautIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (produitsFrigoRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          ProduitFrigo
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._produitsFrigoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).produitsFrigoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (platIngredientsRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          PlatIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._platIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).platIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (repasPlanifiesRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          RepasPlanifie
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._repasPlanifiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).repasPlanifiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (articlesCourseRefs)
                        await $_getPrefetchedData<
                          Produit,
                          $ProduitsTable,
                          ArticleCourse
                        >(
                          currentTable: table,
                          referencedTable: $$ProduitsTableReferences
                              ._articlesCourseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduitsTableReferences(
                                db,
                                table,
                                p0,
                              ).articlesCourseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProduitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProduitsTable,
      Produit,
      $$ProduitsTableFilterComposer,
      $$ProduitsTableOrderingComposer,
      $$ProduitsTableAnnotationComposer,
      $$ProduitsTableCreateCompanionBuilder,
      $$ProduitsTableUpdateCompanionBuilder,
      (Produit, $$ProduitsTableReferences),
      Produit,
      PrefetchHooks Function({
        bool categorieId,
        bool uniteDefautId,
        bool produitsFrigoRefs,
        bool platIngredientsRefs,
        bool repasPlanifiesRefs,
        bool articlesCourseRefs,
      })
    >;
typedef $$ProduitsFrigoTableCreateCompanionBuilder =
    ProduitsFrigoCompanion Function({
      Value<int> id,
      required int produitId,
      required int zoneId,
      required double quantite,
      required int uniteId,
      required DateTime dateAjout,
      Value<DateTime?> datePeremption,
      Value<StatutProduitFrigo> statut,
      Value<DateTime?> dateStatut,
    });
typedef $$ProduitsFrigoTableUpdateCompanionBuilder =
    ProduitsFrigoCompanion Function({
      Value<int> id,
      Value<int> produitId,
      Value<int> zoneId,
      Value<double> quantite,
      Value<int> uniteId,
      Value<DateTime> dateAjout,
      Value<DateTime?> datePeremption,
      Value<StatutProduitFrigo> statut,
      Value<DateTime?> dateStatut,
    });

final class $$ProduitsFrigoTableReferences
    extends BaseReferences<_$AppDatabase, $ProduitsFrigoTable, ProduitFrigo> {
  $$ProduitsFrigoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduitsTable _produitIdTable(_$AppDatabase db) =>
      db.produits.createAlias('produit_frigo__produit_id__produit__id');

  $$ProduitsTableProcessedTableManager get produitId {
    final $_column = $_itemColumn<int>('produit_id')!;

    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ZonesTable _zoneIdTable(_$AppDatabase db) =>
      db.zones.createAlias('produit_frigo__zone_id__zone__id');

  $$ZonesTableProcessedTableManager get zoneId {
    final $_column = $_itemColumn<int>('zone_id')!;

    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitesTable _uniteIdTable(_$AppDatabase db) =>
      db.unites.createAlias('produit_frigo__unite_id__unite__id');

  $$UnitesTableProcessedTableManager get uniteId {
    final $_column = $_itemColumn<int>('unite_id')!;

    final manager = $$UnitesTableTableManager(
      $_db,
      $_db.unites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uniteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProduitsFrigoTableFilterComposer
    extends Composer<_$AppDatabase, $ProduitsFrigoTable> {
  $$ProduitsFrigoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAjout => $composableBuilder(
    column: $table.dateAjout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datePeremption => $composableBuilder(
    column: $table.datePeremption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatutProduitFrigo, StatutProduitFrigo, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dateStatut => $composableBuilder(
    column: $table.dateStatut,
    builder: (column) => ColumnFilters(column),
  );

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableFilterComposer get uniteId {
    final $$UnitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableFilterComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsFrigoTableOrderingComposer
    extends Composer<_$AppDatabase, $ProduitsFrigoTable> {
  $$ProduitsFrigoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAjout => $composableBuilder(
    column: $table.dateAjout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datePeremption => $composableBuilder(
    column: $table.datePeremption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateStatut => $composableBuilder(
    column: $table.dateStatut,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableOrderingComposer get uniteId {
    final $$UnitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableOrderingComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsFrigoTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProduitsFrigoTable> {
  $$ProduitsFrigoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAjout =>
      $composableBuilder(column: $table.dateAjout, builder: (column) => column);

  GeneratedColumn<DateTime> get datePeremption => $composableBuilder(
    column: $table.datePeremption,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<StatutProduitFrigo, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get dateStatut => $composableBuilder(
    column: $table.dateStatut,
    builder: (column) => column,
  );

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableAnnotationComposer get uniteId {
    final $$UnitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableAnnotationComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduitsFrigoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProduitsFrigoTable,
          ProduitFrigo,
          $$ProduitsFrigoTableFilterComposer,
          $$ProduitsFrigoTableOrderingComposer,
          $$ProduitsFrigoTableAnnotationComposer,
          $$ProduitsFrigoTableCreateCompanionBuilder,
          $$ProduitsFrigoTableUpdateCompanionBuilder,
          (ProduitFrigo, $$ProduitsFrigoTableReferences),
          ProduitFrigo,
          PrefetchHooks Function({bool produitId, bool zoneId, bool uniteId})
        > {
  $$ProduitsFrigoTableTableManager(_$AppDatabase db, $ProduitsFrigoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduitsFrigoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduitsFrigoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProduitsFrigoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> produitId = const Value.absent(),
                Value<int> zoneId = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<int> uniteId = const Value.absent(),
                Value<DateTime> dateAjout = const Value.absent(),
                Value<DateTime?> datePeremption = const Value.absent(),
                Value<StatutProduitFrigo> statut = const Value.absent(),
                Value<DateTime?> dateStatut = const Value.absent(),
              }) => ProduitsFrigoCompanion(
                id: id,
                produitId: produitId,
                zoneId: zoneId,
                quantite: quantite,
                uniteId: uniteId,
                dateAjout: dateAjout,
                datePeremption: datePeremption,
                statut: statut,
                dateStatut: dateStatut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int produitId,
                required int zoneId,
                required double quantite,
                required int uniteId,
                required DateTime dateAjout,
                Value<DateTime?> datePeremption = const Value.absent(),
                Value<StatutProduitFrigo> statut = const Value.absent(),
                Value<DateTime?> dateStatut = const Value.absent(),
              }) => ProduitsFrigoCompanion.insert(
                id: id,
                produitId: produitId,
                zoneId: zoneId,
                quantite: quantite,
                uniteId: uniteId,
                dateAjout: dateAjout,
                datePeremption: datePeremption,
                statut: statut,
                dateStatut: dateStatut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProduitsFrigoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({produitId = false, zoneId = false, uniteId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (produitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.produitId,
                                    referencedTable:
                                        $$ProduitsFrigoTableReferences
                                            ._produitIdTable(db),
                                    referencedColumn:
                                        $$ProduitsFrigoTableReferences
                                            ._produitIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (zoneId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.zoneId,
                                    referencedTable:
                                        $$ProduitsFrigoTableReferences
                                            ._zoneIdTable(db),
                                    referencedColumn:
                                        $$ProduitsFrigoTableReferences
                                            ._zoneIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (uniteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.uniteId,
                                    referencedTable:
                                        $$ProduitsFrigoTableReferences
                                            ._uniteIdTable(db),
                                    referencedColumn:
                                        $$ProduitsFrigoTableReferences
                                            ._uniteIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ProduitsFrigoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProduitsFrigoTable,
      ProduitFrigo,
      $$ProduitsFrigoTableFilterComposer,
      $$ProduitsFrigoTableOrderingComposer,
      $$ProduitsFrigoTableAnnotationComposer,
      $$ProduitsFrigoTableCreateCompanionBuilder,
      $$ProduitsFrigoTableUpdateCompanionBuilder,
      (ProduitFrigo, $$ProduitsFrigoTableReferences),
      ProduitFrigo,
      PrefetchHooks Function({bool produitId, bool zoneId, bool uniteId})
    >;
typedef $$PlatsTableCreateCompanionBuilder =
    PlatsCompanion Function({
      Value<int> id,
      required String nom,
      Value<int?> tempsPrepa,
      Value<String?> notes,
      Value<int> portionsDefaut,
    });
typedef $$PlatsTableUpdateCompanionBuilder =
    PlatsCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<int?> tempsPrepa,
      Value<String?> notes,
      Value<int> portionsDefaut,
    });

final class $$PlatsTableReferences
    extends BaseReferences<_$AppDatabase, $PlatsTable, Plat> {
  $$PlatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlatIngredientsTable, List<PlatIngredient>>
  _platIngredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.platIngredients,
    aliasName: 'plat__id__plat_ingredient__plat_id',
  );

  $$PlatIngredientsTableProcessedTableManager get platIngredientsRefs {
    final manager = $$PlatIngredientsTableTableManager(
      $_db,
      $_db.platIngredients,
    ).filter((f) => f.platId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _platIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepasPlanifiesTable, List<RepasPlanifie>>
  _repasPlanifiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repasPlanifies,
    aliasName: 'plat__id__repas_planifie__plat_id',
  );

  $$RepasPlanifiesTableProcessedTableManager get repasPlanifiesRefs {
    final manager = $$RepasPlanifiesTableTableManager(
      $_db,
      $_db.repasPlanifies,
    ).filter((f) => f.platId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repasPlanifiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlatsTableFilterComposer extends Composer<_$AppDatabase, $PlatsTable> {
  $$PlatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tempsPrepa => $composableBuilder(
    column: $table.tempsPrepa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get portionsDefaut => $composableBuilder(
    column: $table.portionsDefaut,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> platIngredientsRefs(
    Expression<bool> Function($$PlatIngredientsTableFilterComposer f) f,
  ) {
    final $$PlatIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.platId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repasPlanifiesRefs(
    Expression<bool> Function($$RepasPlanifiesTableFilterComposer f) f,
  ) {
    final $$RepasPlanifiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repasPlanifies,
      getReferencedColumn: (t) => t.platId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepasPlanifiesTableFilterComposer(
            $db: $db,
            $table: $db.repasPlanifies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlatsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatsTable> {
  $$PlatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tempsPrepa => $composableBuilder(
    column: $table.tempsPrepa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get portionsDefaut => $composableBuilder(
    column: $table.portionsDefaut,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatsTable> {
  $$PlatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<int> get tempsPrepa => $composableBuilder(
    column: $table.tempsPrepa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get portionsDefaut => $composableBuilder(
    column: $table.portionsDefaut,
    builder: (column) => column,
  );

  Expression<T> platIngredientsRefs<T extends Object>(
    Expression<T> Function($$PlatIngredientsTableAnnotationComposer a) f,
  ) {
    final $$PlatIngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.platIngredients,
      getReferencedColumn: (t) => t.platId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatIngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.platIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> repasPlanifiesRefs<T extends Object>(
    Expression<T> Function($$RepasPlanifiesTableAnnotationComposer a) f,
  ) {
    final $$RepasPlanifiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repasPlanifies,
      getReferencedColumn: (t) => t.platId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepasPlanifiesTableAnnotationComposer(
            $db: $db,
            $table: $db.repasPlanifies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatsTable,
          Plat,
          $$PlatsTableFilterComposer,
          $$PlatsTableOrderingComposer,
          $$PlatsTableAnnotationComposer,
          $$PlatsTableCreateCompanionBuilder,
          $$PlatsTableUpdateCompanionBuilder,
          (Plat, $$PlatsTableReferences),
          Plat,
          PrefetchHooks Function({
            bool platIngredientsRefs,
            bool repasPlanifiesRefs,
          })
        > {
  $$PlatsTableTableManager(_$AppDatabase db, $PlatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int?> tempsPrepa = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> portionsDefaut = const Value.absent(),
              }) => PlatsCompanion(
                id: id,
                nom: nom,
                tempsPrepa: tempsPrepa,
                notes: notes,
                portionsDefaut: portionsDefaut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                Value<int?> tempsPrepa = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> portionsDefaut = const Value.absent(),
              }) => PlatsCompanion.insert(
                id: id,
                nom: nom,
                tempsPrepa: tempsPrepa,
                notes: notes,
                portionsDefaut: portionsDefaut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlatsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({platIngredientsRefs = false, repasPlanifiesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (platIngredientsRefs) db.platIngredients,
                    if (repasPlanifiesRefs) db.repasPlanifies,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (platIngredientsRefs)
                        await $_getPrefetchedData<
                          Plat,
                          $PlatsTable,
                          PlatIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$PlatsTableReferences
                              ._platIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlatsTableReferences(
                                db,
                                table,
                                p0,
                              ).platIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.platId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (repasPlanifiesRefs)
                        await $_getPrefetchedData<
                          Plat,
                          $PlatsTable,
                          RepasPlanifie
                        >(
                          currentTable: table,
                          referencedTable: $$PlatsTableReferences
                              ._repasPlanifiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlatsTableReferences(
                                db,
                                table,
                                p0,
                              ).repasPlanifiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.platId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatsTable,
      Plat,
      $$PlatsTableFilterComposer,
      $$PlatsTableOrderingComposer,
      $$PlatsTableAnnotationComposer,
      $$PlatsTableCreateCompanionBuilder,
      $$PlatsTableUpdateCompanionBuilder,
      (Plat, $$PlatsTableReferences),
      Plat,
      PrefetchHooks Function({
        bool platIngredientsRefs,
        bool repasPlanifiesRefs,
      })
    >;
typedef $$PlatIngredientsTableCreateCompanionBuilder =
    PlatIngredientsCompanion Function({
      Value<int> id,
      required int platId,
      required int produitId,
      required double quantite,
      required int uniteId,
    });
typedef $$PlatIngredientsTableUpdateCompanionBuilder =
    PlatIngredientsCompanion Function({
      Value<int> id,
      Value<int> platId,
      Value<int> produitId,
      Value<double> quantite,
      Value<int> uniteId,
    });

final class $$PlatIngredientsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlatIngredientsTable, PlatIngredient> {
  $$PlatIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlatsTable _platIdTable(_$AppDatabase db) =>
      db.plats.createAlias('plat_ingredient__plat_id__plat__id');

  $$PlatsTableProcessedTableManager get platId {
    final $_column = $_itemColumn<int>('plat_id')!;

    final manager = $$PlatsTableTableManager(
      $_db,
      $_db.plats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_platIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProduitsTable _produitIdTable(_$AppDatabase db) =>
      db.produits.createAlias('plat_ingredient__produit_id__produit__id');

  $$ProduitsTableProcessedTableManager get produitId {
    final $_column = $_itemColumn<int>('produit_id')!;

    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitesTable _uniteIdTable(_$AppDatabase db) =>
      db.unites.createAlias('plat_ingredient__unite_id__unite__id');

  $$UnitesTableProcessedTableManager get uniteId {
    final $_column = $_itemColumn<int>('unite_id')!;

    final manager = $$UnitesTableTableManager(
      $_db,
      $_db.unites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uniteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlatIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $PlatIngredientsTable> {
  $$PlatIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  $$PlatsTableFilterComposer get platId {
    final $$PlatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableFilterComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableFilterComposer get uniteId {
    final $$UnitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableFilterComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatIngredientsTable> {
  $$PlatIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlatsTableOrderingComposer get platId {
    final $$PlatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableOrderingComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableOrderingComposer get uniteId {
    final $$UnitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableOrderingComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatIngredientsTable> {
  $$PlatIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  $$PlatsTableAnnotationComposer get platId {
    final $$PlatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableAnnotationComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableAnnotationComposer get uniteId {
    final $$UnitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableAnnotationComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlatIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatIngredientsTable,
          PlatIngredient,
          $$PlatIngredientsTableFilterComposer,
          $$PlatIngredientsTableOrderingComposer,
          $$PlatIngredientsTableAnnotationComposer,
          $$PlatIngredientsTableCreateCompanionBuilder,
          $$PlatIngredientsTableUpdateCompanionBuilder,
          (PlatIngredient, $$PlatIngredientsTableReferences),
          PlatIngredient,
          PrefetchHooks Function({bool platId, bool produitId, bool uniteId})
        > {
  $$PlatIngredientsTableTableManager(
    _$AppDatabase db,
    $PlatIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> platId = const Value.absent(),
                Value<int> produitId = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<int> uniteId = const Value.absent(),
              }) => PlatIngredientsCompanion(
                id: id,
                platId: platId,
                produitId: produitId,
                quantite: quantite,
                uniteId: uniteId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int platId,
                required int produitId,
                required double quantite,
                required int uniteId,
              }) => PlatIngredientsCompanion.insert(
                id: id,
                platId: platId,
                produitId: produitId,
                quantite: quantite,
                uniteId: uniteId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlatIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({platId = false, produitId = false, uniteId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (platId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.platId,
                                    referencedTable:
                                        $$PlatIngredientsTableReferences
                                            ._platIdTable(db),
                                    referencedColumn:
                                        $$PlatIngredientsTableReferences
                                            ._platIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (produitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.produitId,
                                    referencedTable:
                                        $$PlatIngredientsTableReferences
                                            ._produitIdTable(db),
                                    referencedColumn:
                                        $$PlatIngredientsTableReferences
                                            ._produitIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (uniteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.uniteId,
                                    referencedTable:
                                        $$PlatIngredientsTableReferences
                                            ._uniteIdTable(db),
                                    referencedColumn:
                                        $$PlatIngredientsTableReferences
                                            ._uniteIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PlatIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatIngredientsTable,
      PlatIngredient,
      $$PlatIngredientsTableFilterComposer,
      $$PlatIngredientsTableOrderingComposer,
      $$PlatIngredientsTableAnnotationComposer,
      $$PlatIngredientsTableCreateCompanionBuilder,
      $$PlatIngredientsTableUpdateCompanionBuilder,
      (PlatIngredient, $$PlatIngredientsTableReferences),
      PlatIngredient,
      PrefetchHooks Function({bool platId, bool produitId, bool uniteId})
    >;
typedef $$RepasPlanifiesTableCreateCompanionBuilder =
    RepasPlanifiesCompanion Function({
      Value<int> id,
      required DateTime date,
      Value<int?> platId,
      Value<int?> produitId,
      required int portions,
      Value<StatutRepas> statut,
    });
typedef $$RepasPlanifiesTableUpdateCompanionBuilder =
    RepasPlanifiesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int?> platId,
      Value<int?> produitId,
      Value<int> portions,
      Value<StatutRepas> statut,
    });

final class $$RepasPlanifiesTableReferences
    extends BaseReferences<_$AppDatabase, $RepasPlanifiesTable, RepasPlanifie> {
  $$RepasPlanifiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlatsTable _platIdTable(_$AppDatabase db) =>
      db.plats.createAlias('repas_planifie__plat_id__plat__id');

  $$PlatsTableProcessedTableManager? get platId {
    final $_column = $_itemColumn<int>('plat_id');
    if ($_column == null) return null;
    final manager = $$PlatsTableTableManager(
      $_db,
      $_db.plats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_platIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProduitsTable _produitIdTable(_$AppDatabase db) =>
      db.produits.createAlias('repas_planifie__produit_id__produit__id');

  $$ProduitsTableProcessedTableManager? get produitId {
    final $_column = $_itemColumn<int>('produit_id');
    if ($_column == null) return null;
    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepasPlanifiesTableFilterComposer
    extends Composer<_$AppDatabase, $RepasPlanifiesTable> {
  $$RepasPlanifiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatutRepas, StatutRepas, String> get statut =>
      $composableBuilder(
        column: $table.statut,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PlatsTableFilterComposer get platId {
    final $$PlatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableFilterComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepasPlanifiesTableOrderingComposer
    extends Composer<_$AppDatabase, $RepasPlanifiesTable> {
  $$RepasPlanifiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlatsTableOrderingComposer get platId {
    final $$PlatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableOrderingComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepasPlanifiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepasPlanifiesTable> {
  $$RepasPlanifiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get portions =>
      $composableBuilder(column: $table.portions, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StatutRepas, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  $$PlatsTableAnnotationComposer get platId {
    final $$PlatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.platId,
      referencedTable: $db.plats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlatsTableAnnotationComposer(
            $db: $db,
            $table: $db.plats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepasPlanifiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepasPlanifiesTable,
          RepasPlanifie,
          $$RepasPlanifiesTableFilterComposer,
          $$RepasPlanifiesTableOrderingComposer,
          $$RepasPlanifiesTableAnnotationComposer,
          $$RepasPlanifiesTableCreateCompanionBuilder,
          $$RepasPlanifiesTableUpdateCompanionBuilder,
          (RepasPlanifie, $$RepasPlanifiesTableReferences),
          RepasPlanifie,
          PrefetchHooks Function({bool platId, bool produitId})
        > {
  $$RepasPlanifiesTableTableManager(
    _$AppDatabase db,
    $RepasPlanifiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepasPlanifiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepasPlanifiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepasPlanifiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> platId = const Value.absent(),
                Value<int?> produitId = const Value.absent(),
                Value<int> portions = const Value.absent(),
                Value<StatutRepas> statut = const Value.absent(),
              }) => RepasPlanifiesCompanion(
                id: id,
                date: date,
                platId: platId,
                produitId: produitId,
                portions: portions,
                statut: statut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                Value<int?> platId = const Value.absent(),
                Value<int?> produitId = const Value.absent(),
                required int portions,
                Value<StatutRepas> statut = const Value.absent(),
              }) => RepasPlanifiesCompanion.insert(
                id: id,
                date: date,
                platId: platId,
                produitId: produitId,
                portions: portions,
                statut: statut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RepasPlanifiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({platId = false, produitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (platId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.platId,
                                referencedTable: $$RepasPlanifiesTableReferences
                                    ._platIdTable(db),
                                referencedColumn:
                                    $$RepasPlanifiesTableReferences
                                        ._platIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (produitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.produitId,
                                referencedTable: $$RepasPlanifiesTableReferences
                                    ._produitIdTable(db),
                                referencedColumn:
                                    $$RepasPlanifiesTableReferences
                                        ._produitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RepasPlanifiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepasPlanifiesTable,
      RepasPlanifie,
      $$RepasPlanifiesTableFilterComposer,
      $$RepasPlanifiesTableOrderingComposer,
      $$RepasPlanifiesTableAnnotationComposer,
      $$RepasPlanifiesTableCreateCompanionBuilder,
      $$RepasPlanifiesTableUpdateCompanionBuilder,
      (RepasPlanifie, $$RepasPlanifiesTableReferences),
      RepasPlanifie,
      PrefetchHooks Function({bool platId, bool produitId})
    >;
typedef $$ArticlesCourseTableCreateCompanionBuilder =
    ArticlesCourseCompanion Function({
      Value<int> id,
      required int produitId,
      required double quantite,
      required int uniteId,
      Value<OrigineArticle> origine,
      Value<StatutArticle> statut,
    });
typedef $$ArticlesCourseTableUpdateCompanionBuilder =
    ArticlesCourseCompanion Function({
      Value<int> id,
      Value<int> produitId,
      Value<double> quantite,
      Value<int> uniteId,
      Value<OrigineArticle> origine,
      Value<StatutArticle> statut,
    });

final class $$ArticlesCourseTableReferences
    extends BaseReferences<_$AppDatabase, $ArticlesCourseTable, ArticleCourse> {
  $$ArticlesCourseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduitsTable _produitIdTable(_$AppDatabase db) =>
      db.produits.createAlias('article_course__produit_id__produit__id');

  $$ProduitsTableProcessedTableManager get produitId {
    final $_column = $_itemColumn<int>('produit_id')!;

    final manager = $$ProduitsTableTableManager(
      $_db,
      $_db.produits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitesTable _uniteIdTable(_$AppDatabase db) =>
      db.unites.createAlias('article_course__unite_id__unite__id');

  $$UnitesTableProcessedTableManager get uniteId {
    final $_column = $_itemColumn<int>('unite_id')!;

    final manager = $$UnitesTableTableManager(
      $_db,
      $_db.unites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_uniteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticlesCourseTableFilterComposer
    extends Composer<_$AppDatabase, $ArticlesCourseTable> {
  $$ArticlesCourseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OrigineArticle, OrigineArticle, String>
  get origine => $composableBuilder(
    column: $table.origine,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<StatutArticle, StatutArticle, String>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ProduitsTableFilterComposer get produitId {
    final $$ProduitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableFilterComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableFilterComposer get uniteId {
    final $$UnitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableFilterComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesCourseTableOrderingComposer
    extends Composer<_$AppDatabase, $ArticlesCourseTable> {
  $$ArticlesCourseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origine => $composableBuilder(
    column: $table.origine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduitsTableOrderingComposer get produitId {
    final $$ProduitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableOrderingComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableOrderingComposer get uniteId {
    final $$UnitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableOrderingComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesCourseTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArticlesCourseTable> {
  $$ArticlesCourseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OrigineArticle, String> get origine =>
      $composableBuilder(column: $table.origine, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StatutArticle, String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  $$ProduitsTableAnnotationComposer get produitId {
    final $$ProduitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produitId,
      referencedTable: $db.produits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduitsTableAnnotationComposer(
            $db: $db,
            $table: $db.produits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitesTableAnnotationComposer get uniteId {
    final $$UnitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uniteId,
      referencedTable: $db.unites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitesTableAnnotationComposer(
            $db: $db,
            $table: $db.unites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesCourseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArticlesCourseTable,
          ArticleCourse,
          $$ArticlesCourseTableFilterComposer,
          $$ArticlesCourseTableOrderingComposer,
          $$ArticlesCourseTableAnnotationComposer,
          $$ArticlesCourseTableCreateCompanionBuilder,
          $$ArticlesCourseTableUpdateCompanionBuilder,
          (ArticleCourse, $$ArticlesCourseTableReferences),
          ArticleCourse,
          PrefetchHooks Function({bool produitId, bool uniteId})
        > {
  $$ArticlesCourseTableTableManager(
    _$AppDatabase db,
    $ArticlesCourseTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesCourseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesCourseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesCourseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> produitId = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<int> uniteId = const Value.absent(),
                Value<OrigineArticle> origine = const Value.absent(),
                Value<StatutArticle> statut = const Value.absent(),
              }) => ArticlesCourseCompanion(
                id: id,
                produitId: produitId,
                quantite: quantite,
                uniteId: uniteId,
                origine: origine,
                statut: statut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int produitId,
                required double quantite,
                required int uniteId,
                Value<OrigineArticle> origine = const Value.absent(),
                Value<StatutArticle> statut = const Value.absent(),
              }) => ArticlesCourseCompanion.insert(
                id: id,
                produitId: produitId,
                quantite: quantite,
                uniteId: uniteId,
                origine: origine,
                statut: statut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArticlesCourseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produitId = false, uniteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (produitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.produitId,
                                referencedTable: $$ArticlesCourseTableReferences
                                    ._produitIdTable(db),
                                referencedColumn:
                                    $$ArticlesCourseTableReferences
                                        ._produitIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (uniteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.uniteId,
                                referencedTable: $$ArticlesCourseTableReferences
                                    ._uniteIdTable(db),
                                referencedColumn:
                                    $$ArticlesCourseTableReferences
                                        ._uniteIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArticlesCourseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArticlesCourseTable,
      ArticleCourse,
      $$ArticlesCourseTableFilterComposer,
      $$ArticlesCourseTableOrderingComposer,
      $$ArticlesCourseTableAnnotationComposer,
      $$ArticlesCourseTableCreateCompanionBuilder,
      $$ArticlesCourseTableUpdateCompanionBuilder,
      (ArticleCourse, $$ArticlesCourseTableReferences),
      ArticleCourse,
      PrefetchHooks Function({bool produitId, bool uniteId})
    >;
typedef $$ReglagesTableCreateCompanionBuilder =
    ReglagesCompanion Function({
      required String cle,
      required String valeur,
      Value<int> rowid,
    });
typedef $$ReglagesTableUpdateCompanionBuilder =
    ReglagesCompanion Function({
      Value<String> cle,
      Value<String> valeur,
      Value<int> rowid,
    });

class $$ReglagesTableFilterComposer
    extends Composer<_$AppDatabase, $ReglagesTable> {
  $$ReglagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReglagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReglagesTable> {
  $$ReglagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cle => $composableBuilder(
    column: $table.cle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valeur => $composableBuilder(
    column: $table.valeur,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReglagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReglagesTable> {
  $$ReglagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cle =>
      $composableBuilder(column: $table.cle, builder: (column) => column);

  GeneratedColumn<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => column);
}

class $$ReglagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReglagesTable,
          Reglage,
          $$ReglagesTableFilterComposer,
          $$ReglagesTableOrderingComposer,
          $$ReglagesTableAnnotationComposer,
          $$ReglagesTableCreateCompanionBuilder,
          $$ReglagesTableUpdateCompanionBuilder,
          (Reglage, BaseReferences<_$AppDatabase, $ReglagesTable, Reglage>),
          Reglage,
          PrefetchHooks Function()
        > {
  $$ReglagesTableTableManager(_$AppDatabase db, $ReglagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReglagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReglagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReglagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cle = const Value.absent(),
                Value<String> valeur = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReglagesCompanion(cle: cle, valeur: valeur, rowid: rowid),
          createCompanionCallback:
              ({
                required String cle,
                required String valeur,
                Value<int> rowid = const Value.absent(),
              }) => ReglagesCompanion.insert(
                cle: cle,
                valeur: valeur,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReglagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReglagesTable,
      Reglage,
      $$ReglagesTableFilterComposer,
      $$ReglagesTableOrderingComposer,
      $$ReglagesTableAnnotationComposer,
      $$ReglagesTableCreateCompanionBuilder,
      $$ReglagesTableUpdateCompanionBuilder,
      (Reglage, BaseReferences<_$AppDatabase, $ReglagesTable, Reglage>),
      Reglage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ZonesTableTableManager get zones =>
      $$ZonesTableTableManager(_db, _db.zones);
  $$UnitesTableTableManager get unites =>
      $$UnitesTableTableManager(_db, _db.unites);
  $$ProduitsTableTableManager get produits =>
      $$ProduitsTableTableManager(_db, _db.produits);
  $$ProduitsFrigoTableTableManager get produitsFrigo =>
      $$ProduitsFrigoTableTableManager(_db, _db.produitsFrigo);
  $$PlatsTableTableManager get plats =>
      $$PlatsTableTableManager(_db, _db.plats);
  $$PlatIngredientsTableTableManager get platIngredients =>
      $$PlatIngredientsTableTableManager(_db, _db.platIngredients);
  $$RepasPlanifiesTableTableManager get repasPlanifies =>
      $$RepasPlanifiesTableTableManager(_db, _db.repasPlanifies);
  $$ArticlesCourseTableTableManager get articlesCourse =>
      $$ArticlesCourseTableTableManager(_db, _db.articlesCourse);
  $$ReglagesTableTableManager get reglages =>
      $$ReglagesTableTableManager(_db, _db.reglages);
}
