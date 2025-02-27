# Backend project

This project is a [Express.js](https://expressjs.com/) server that provides an API to authenticate users and retrieve super secrets.

## Installation

1. Install [Node.js](https://nodejs.org/en/download/)
2. Install the dependencies by running `npm install`

```bash
npm install
```

## Running the server

To run the server, run the following command:

```bash
npm start
```

The server will be running on [http://localhost:8080](http://localhost:8080).

## API

The server has the following endpoints:

- `POST /login`: Creates a new session for the user.

#### Body

```json
{
  "id": "1234",
  "password": "my-secret-password"
}
```

#### Response

```json
{
  "data": {
    "message": "Login successful",
    "user": {
      "id": "1234",
      "token": "cid8lpexp8xk"
    }
  }
}
```

- `GET /super-secrets?id=<USER_ID>`: Returns the super secrets for the user.

#### Query parameters

- `id`: The user ID.

#### Headers

```json
{
  "Authorization": "Bearer <TOKEN>"
}
```

#### Response

```json
{
  "data": {
    "secrets": [
      {
        "name": "superSecret",
        "description": "This is a super secret"
      },
      {
        "name": "firebaseApiKey",
        "description": "Firebase API Key"
      },
      {
        "name": "stripeApiKey",
        "description": "Stripe API Key"
      }
    ]
  }
}
```
