# plik: Dockerfile
FROM ruby:3.2.2

# Instalacja podstawowych zależności + przygotowanie do instalacji Node.js 20
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    curl \
    gnupg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalacja Node.js 20
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -qq && apt-get install -y nodejs

# Włączenie Yarn i ustawienie wersji
RUN corepack enable
RUN corepack prepare yarn@1.22.22 --activate

# Ustawienie katalogu roboczego
WORKDIR /app

# KLUCZOWE: Dodanie node_modules/.bin do PATH
ENV PATH="/app/node_modules/.bin:$PATH"

# Instalacja gemów Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Instalacja pakietów Node.js
COPY package.json yarn.lock ./
RUN yarn install

# Sprawdzenie czy pakiety są dostępne (opcjonalne - dla debugowania)
RUN which webpack && which sass

# Kopiowanie reszty aplikacji
COPY . .

# Nadanie uprawnień do wykonania
RUN chmod +x ./bin/dev

CMD ["./bin/dev"]