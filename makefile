up:
	docker compose -f ./backend/docker-compose.yml up -d api
	supabase start
build:
	docker compose -f ./backend/docker-compose.yml up --build -d api
down:
	docker compose -f ./backend/docker-compose.yml down api
	supabase stop
ps:
	docker compose -f ./backend/docker-compose.yml ps api
