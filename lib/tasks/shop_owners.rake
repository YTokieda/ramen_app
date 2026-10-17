namespace :shop_owners do
  desc "審査から一定期間たった店舗オーナーの営業許可証を削除する"
  task purge_expired_licenses: :environment do
    ShopOwner.purge_expired_licenses!
  end
end
