import express from "express";

// Create an express app
const app = express();

// Configure the express app to parse JSON
app.use(express.json());

// Represents the mock users that are allowed to access the secrets
// In a real-world scenario, you would fetch this data from a database or a third-party service
const allowedUsers = [
  {
    id: "1234",
    password: "my-secret-password",
    // This is the token that is used to authenticate the user
    // In a real-world scenario, you would generate a token and store it in a database
    // For this example, we will generate a random token each time the user logs in
    token: null,
  },
];

// Represents the mock secrets that are stored in the backend
// In a real-world scenario, you would fetch this data from a database or a third-party service
const superSecrets = {
  secrets: [
    {
      name: "superSecret",
      value: "your-super-secret-value",
      description: "This is a super secret",
    },
    {
      name: "firebaseApiKey",
      value: "your-firebase-api-key",
      description: "Firebase API Key",
    },
    {
      name: "stripeApiKey",
      value: "your-stripe-api-key",
      description: "Stripe API Key",
    },
  ],
};

// This is a mock login endpoint that is used to authenticate the user
app.post("/login", (request, response) => {
  const id = request.body?.id;
  const password = request.body?.password;

  // Check if the request is valid
  if (!id || !password) {
    return response.status(422).json({
      message: "Unprocessable entity",
      code: 422,
    });
  }

  // Check if the user is allowed to access the secrets
  // In a real-world scenario, you would validate the user against a database or a third-party service
  const user = allowedUsers.find(
    (user) => user.id === id && user.password === password
  );

  if (!user) {
    return response.status(409).json({
      message: "Invalid credentials",
      code: 409,
    });
  }

  // Generate a random token for the user
  user.token =
    Math.random().toString(36).substring(7) +
    Math.random().toString(36).substring(7);

  response.json({
    data: {
      message: "Login successful",
      user: {
        id: user.id,
        token: user.token,
      },
    },
  });
});

// This is a mock endpoint that is used to fetch the super secrets
app.get("/super-secrets", (request, response) => {
  const { id } = request.query;
  const { authorization } = request.headers;

  // Extract the token from the authorization header
  const token = authorization?.replace("Bearer ", "");

  // Check if the token is valid
  // In a real-world scenario, you would validate the token against a database or a third-party service
  const user = allowedUsers.find((user) => user.id === id);
  const isTokenValid = user?.token === token;

  if (!user || !isTokenValid) {
    return response.status(401).json({
      message: "Unauthorized",
      code: 401,
    });
  }

  response.json({
    data: {
      ...superSecrets,
    },
  });
});

// Start the express app
app.listen(8080, () => {
  console.log("Server is running on port 8080");
});
