options = { table_name: '_sample_app_session', key: 'should not be here' }
Rails.application.config.session_store :dynamo_db_store, **options
