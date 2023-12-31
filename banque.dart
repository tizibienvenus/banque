const typeErreur = "erreur";
const typeInfo = "info";
const typeBanque = "banque";
const typeClient = "client";

const minEpargne = 15000;

Map<String, String> icones = {
  typeErreur: "[❌]",
  typeInfo: "[✅]",
  typeBanque: "[📢]",
  typeClient: "[😎]",
};

void printSympa(String type, String message) {
  var icon = icones[type];
  print("$icon $message");
}

class Client {
  int numeroClient;
  String nom;
  String prenom;
  String numeroTelephone;
  String adresse;
  String? numeroCni;

  Client({
    required this.numeroClient,
    required this.nom,
    required this.prenom,
    required this.numeroTelephone,
    required this.adresse,
    this.numeroCni,
  });

  factory Client.fromCni(
    int numero,
    Map<String, dynamic> cni,
    String numeroTelephone,
  ) {
    return Client(
      numeroClient: numero,
      nom: cni['nom'],
      prenom: cni['prenom'],
      numeroTelephone: numeroTelephone,
      adresse: cni['adresse'],
      numeroCni: cni['numero'],
    );
  }

  String nomComplet() {
    return "$nom $prenom";
  }
}

class CompteBancaire {
  int numeroCompte;
  double _solde;
  String type;
  Client client;

  CompteBancaire(
    this.numeroCompte,
    this._solde,
    this.type,
    this.client,
  );

  factory CompteBancaire.courant(int numero, Client client,
      [double soldeInitial = 0]) {
    return CompteBancaire(
      numero,
      soldeInitial,
      "courant",
      client,
    );
  }

  factory CompteBancaire.epargne(
      int numero, Client client, double soldeInitial) {
    return CompteBancaire(
      numero,
      soldeInitial,
      "epargne",
      client,
    );
  }

  void deposer(double montant) {
    _solde += montant;
  }

  bool retirer(double montant) {
    if (montant <= 0 || montant > _solde) {
      return false;
    }
    _solde -= montant;

    return true;
  }

  double soldeDuCompte() {
    return _solde;
  }

  void informationDuCompte() {
    printSympa(typeBanque, "Numéro de compte : $numeroCompte");
    print("Type de compte : $type");
    print("Solde disponible : $_solde");
  }
}

class Banque {
  List<Client> clients = [];
  List<CompteBancaire> compteBancaires = [];

  CompteBancaire? _recupereCompte(int numeroCompte) {
    CompteBancaire? compte = compteBancaires
        .where((c) => c.numeroCompte == numeroCompte)
        .firstOrNull;
    return compte;
  }

  Client? _recupereClient(int numeroClient) {
    Client? client =
        clients.where((c) => c.numeroClient == numeroClient).firstOrNull;
    return client;
  }

  bool _verifierConformiter(int numeroClient, [int? numeroCompte]) {
    Client? client = _recupereClient(numeroClient);
    if (client == null) {
      printSympa(
        typeErreur,
        "Le client $numeroClient n'existe pas dans le système!",
      );
      return false;
    }

    if (numeroCompte == null) {
      return false;
    }

    CompteBancaire? compte = _recupereCompte(numeroCompte);
    if (compte == null) {
      printSympa(
        typeErreur,
        "Le compte $numeroCompte n'existe pas dans le système!",
      );
      return false;
    }

    if (compte.client.numeroClient != numeroClient) {
      printSympa(
        typeErreur,
        "Le compte $numeroCompte n'appartient pas au client $numeroClient",
      );
      return false;
    }

    return true;
  }

  void depotEnAgence({
    required int numeroClient,
    required int numeroCompte,
    required double montant,
  }) {
    bool estConforme = _verifierConformiter(numeroClient, numeroCompte);
    if (!estConforme) {
      return;
    }

    CompteBancaire compte = _recupereCompte(numeroCompte)!;
    compte.deposer(montant);
    printSympa(
      typeInfo,
      "Le depot de $montant a été effectué sur le compte numéro : ${compte.numeroCompte} du client : ${compte.client.nomComplet()}!",
    );
  }

  void retirerEnAgence({
    required int numeroClient,
    required int numeroCompte,
    required double montant,
  }) {
    bool estConforme = _verifierConformiter(numeroClient, numeroCompte);
    if (!estConforme) {
      printSympa(
        typeErreur,
        "Problème de conformité, le retrait ne peut pas être effectué!",
      );
      return;
    }

    CompteBancaire compte = _recupereCompte(numeroCompte)!;
    if (compte.retirer(montant)) {
      printSympa(
        typeInfo,
        "Le retrait de $montant a été effectué avec succès sur le compte ${compte.numeroCompte} du client ${compte.client.nomComplet()}!",
      );
    } else {
      printSympa(
        typeErreur,
        "${compte.client.nomComplet()} n'a pas assez d'argent dans son compte ${compte.type} 😂😂",
      );
    }
  }

  void nouveauClient(Map<String, dynamic> cni, String telephone) {
    int nouveauNumero = clients.length + 1;
    Client nouveauClient = Client.fromCni(nouveauNumero, cni, telephone);
    clients.add(nouveauClient);

    printSympa(
      typeClient,
      "Le client ${nouveauClient.nomComplet()} a été ajouté avec succès! Numero de compte : $nouveauNumero",
    );
  }

  bool _aDejaUnCompte(int numeroClient, String type) {
    bool existeDeja = compteBancaires
        .any((c) => c.type == type && c.client.numeroClient == numeroClient);

    if (existeDeja) {
      printSympa(
        typeErreur,
        "Oh non! 😒 Le client $numeroClient a déjà un compte $type",
      );
      return true;
    }
    return false;
  }

  void nouveauCompteEpargne({
    required int numeroClient,
    required double montantInitial,
  }) {
    if (montantInitial < minEpargne) {
      double difference = minEpargne - montantInitial;
      printSympa(
        typeErreur,
        "😦 Argent trop peu pour compte épargne, ajoute $difference pour atteindre $minEpargne",
      );
      return;
    }

    bool estConforme = _verifierConformiter(numeroClient);
    if (estConforme) {
      return;
    }

    if (_aDejaUnCompte(numeroClient, "epargne")) {
      return;
    }

    Client client = _recupereClient(numeroClient)!;

    int numeroCompte = compteBancaires.length + 1;
    CompteBancaire compte =
        CompteBancaire.epargne(numeroCompte, client, montantInitial);
    compteBancaires.add(compte);

    printSympa(
      typeBanque,
      "Le compte ${compte.numeroCompte} a été créé avec succès 👍",
    );
  }

  void nouveauCompteCourant({
    required int numeroClient,
    double montantInitial = 0,
  }) {
    bool estConforme = _verifierConformiter(numeroClient);
    if (estConforme) {
      return;
    }

    if (_aDejaUnCompte(numeroClient, "courant")) {
      return;
    }

    Client client = _recupereClient(numeroClient)!;

    int numeroCompte = compteBancaires.length + 1;
    CompteBancaire compte =
        CompteBancaire.courant(numeroCompte, client, montantInitial);
    compteBancaires.add(compte);

    printSympa(
      typeBanque,
      "Le compte ${compte.numeroCompte} a été créé avec succès 👍",
    );
  }

  void etatComplet() {
    print("\n");
    print('-' * 50);
    printSympa(
      typeBanque,
      "Etat de la  Banque",
    );
    print("Nombre de clients: ${clients.length}");
    print("Nombre de comptes : ${compteBancaires.length}");

    print("-" * 20);
    for (var client in clients) {
      var comptesClient = compteBancaires
          .where((c) => c.client.numeroClient == client.numeroClient)
          .toList();

      printSympa(
        typeClient,
        "${client.nomComplet()} (${client.numeroTelephone})",
      );

      print("Adresse : ${client.adresse}");
      print("Comptes disponibles : ${comptesClient.length}");

      for (var compte in comptesClient) {
        compte.informationDuCompte();
        print("-" * 5);
      }

      print('-' * 15);
    }
    print("\n");
  }
}

void main() {
  print("=" * 50);
  print("====== Bienvenu à la banque BISMUCH DIVERS  ======");
  print("====== la banque qui cache bien l'argent 😉 ======");
  print("=" * 50);

  Banque banque = Banque();

  Map<String, dynamic> cni1 = {
    'numero': '01-24220/CG',
    'nom': 'Jean',
    'prenom': 'Malonga',
    'adresse': 'Près de la route',
  };

  banque.nouveauClient(cni1, "061007525");

  Map<String, dynamic> cni2 = {
    'numero': '25-24250/BZ',
    'nom': 'Mongo',
    'prenom': 'La montagne',
    'adresse': 'A coter du bar',
  };
  banque.nouveauClient(cni2, "051007525");

  banque.etatComplet();

  banque.nouveauCompteCourant(numeroClient: 1, montantInitial: 10000);
  banque.nouveauCompteCourant(numeroClient: 1, montantInitial: 5000);

  banque.nouveauCompteEpargne(numeroClient: 1, montantInitial: 2000);
  banque.nouveauCompteEpargne(numeroClient: 1, montantInitial: 30000);

  print("-" * 50);

  banque.depotEnAgence(numeroClient: 1, numeroCompte: 3, montant: 1000);
  banque.depotEnAgence(numeroClient: 1, numeroCompte: 2, montant: 10000);
  banque.retirerEnAgence(numeroClient: 1, numeroCompte: 1, montant: 50000);
  banque.depotEnAgence(numeroClient: 1, numeroCompte: 2, montant: 50000);
  banque.depotEnAgence(numeroClient: 2, numeroCompte: 2, montant: 50000);
  banque.retirerEnAgence(numeroClient: 2, numeroCompte: 1, montant: 5000);

  banque.etatComplet();
}
