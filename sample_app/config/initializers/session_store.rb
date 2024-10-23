options = { table_name: '_sample_app_sessions', key: '_sample_app_session' }
Rails.application.config.session_store :dynamo_db_store, **options
