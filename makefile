up:
	docker compose up -d
	supabase start
build:
	docker compose up --build -d
down:
	docker compose down
	supabase stop
