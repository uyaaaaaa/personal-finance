up:
	supabase start
	docker compose -f ./backend/docker-compose.yml up -d
build:
	docker compose -f ./backend/docker-compose.yml up --build -d
stop:
	docker compose -f ./backend/docker-compose.yml stop
down:
	docker compose -f ./backend/docker-compose.yml down
	supabase stop
ps:
	docker compose -f ./backend/docker-compose.yml ps
