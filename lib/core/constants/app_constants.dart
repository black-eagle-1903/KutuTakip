/// App-wide constants and predefined values
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ============ DESTINATIONS ============
  static const List<String> predefinedDestinations = [
    'Yeni Ev',
    'Eski Ev',
    'Yazlık Ev',
    'Depo',
    'Diğer',
  ];

  // ============ BOX STATUS ============
  static const String statusPending = 'Beklemede';
  static const String statusMoved = 'Taşındı';

  static const List<String> boxStatuses = [
    statusPending,
    statusMoved,
  ];

  // ============ PHOTO CATEGORIES ============
  static const String categoryExterior = 'Dış';
  static const String categoryInterior = 'İç';
  static const String categoryOther = 'Diğer';

  static const List<String> photoCategories = [
    categoryExterior,
    categoryInterior,
    categoryOther,
  ];

  // ============ UI STRINGS (Turkish) ============
  // Titles
  static const String appTitle = 'KutuTakip';
  static const String dashboardTitle = 'Pano';
  static const String boxesTitle = 'Kutular';
  static const String newBoxTitle = 'Yeni Kutu';
  static const String editBoxTitle = 'Kutuyu Düzenle';
  static const String searchTitle = 'Ara';
  static const String backupTitle = 'Yedekleme';

  // Labels
  static const String boxNumberLabel = 'Kutu Numarası';
  static const String titleLabel = 'Başlık';
  static const String descriptionLabel = 'Açıklama';
  static const String destinationLabel = 'Hedef Konum';
  static const String statusLabel = 'Durum';
  static const String notesLabel = 'Notlar';
  static const String itemsLabel = 'Eşyalar';
  static const String photosLabel = 'Fotoğraflar';
  static const String categoryLabel = 'Kategori';
  static const String quantityLabel = 'Miktar';
  static const String fragileLabel = 'Kırılgan';

  // Buttons
  static const String addButton = 'Ekle';
  static const String createButton = 'Oluştur';
  static const String saveButton = 'Kaydet';
  static const String updateButton = 'Güncelle';
  static const String deleteButton = 'Sil';
  static const String cancelButton = 'İptal';
  static const String searchButton = 'Ara';
  static const String backButton = 'Geri';
  static const String nextButton = 'İleri';
  static const String doneButton = 'Bitti';

  // Actions
  static const String takePhotoAction = 'Fotoğraf Çek';
  static const String selectPhotoAction = 'Galeriden Seç';
  static const String addItemAction = 'Eşya Ekle';
  static const String addPhotoAction = 'Fotoğraf Ekle';
  static const String backupAction = 'Yedekle';
  static const String restoreAction = 'Geri Yükle';
  static const String deleteConfirmAction = 'Sil';

  // Messages
  static const String confirmDeleteMessage = 'Silmek istediğinizden emin misiniz?';
  static const String deleteSuccessMessage = 'Silindi.';
  static const String createSuccessMessage = 'Oluşturuldu.';
  static const String updateSuccessMessage = 'Güncellendi.';
  static const String errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String noBoxesMessage = 'Henüz kutu yok. Yeni kutu oluşturmak için + butonuna dokunun.';
  static const String noItemsMessage = 'Bu kutuda eşya yok.';
  static const String noPhotosMessage = 'Bu kutuda fotoğraf yok.';
  static const String backupSuccessMessage = 'Yedekleme başarılı.';
  static const String restoreSuccessMessage = 'Geri yükleme başarılı.';

  // ============ PAGINATION & DISPLAY ============
  static const int itemsPerPage = 20;
  static const int maxPhotoCompressDimension = 1024;
  static const int photoCompressQuality = 85;

  // ============ DATABASE ============
  static const String databaseName = 'kututakip.db';
  static const int databaseVersion = 1;

  // ============ FILE STORAGE ============
  static const String photosDirectoryName = 'photos';
  static const String backupDirectoryName = 'backups';
  static const String metadataFileName = 'metadata.json';
  static const String photosDirNameInZip = 'photos';
}
