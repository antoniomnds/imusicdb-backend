onBoarding App III

Create a React application that communicates with a Rails Application (API module) that can store structured data and can communicate with other external APIs.
In the example, the Spotify and openAi api will be used as an example

Create an Rails API https://guides.rubyonrails.org/api_app.html
Create a React App (https://vite.dev/guide/)

# Spotify API https://developer.spotify.com/documentation/web-api
# OpenAI API https://platform.openai.com/docs/overview

### NOTES:
  - ALL calls to Spotify MUST be made by the rails api module
  - React APP should communicate with the main api using JSON Web Tokens https://jwt.io/
  - The key to use openAi should be provided by the #rails-unit (joão Ferreira) DO NOT COMMIT API KEYS :)
  - The ETD (Estimated Time of Delivery) is only representative, needs to be modified by the developer and added to READ.ME (repository), so that it can be seen whether the work done falls within the estimates (theoretically)(Estimations will in  presented to a client)
  - Rails API PRs should be reviewed by (Carlos Palma, Daniel Carvalho, Luis Costa)
  - React App PRs should be reviewed by (Marcos Germano)

### RAILS
- Create Rails Api module (ETD : 1 hour)(Antonio ETD: 1h)
- Add the proper configuration to start to communicate with Spotify, openAI (ETD: 2 to 3 hours)(Antonio ETD: 3h)

### RAILS API SHOULD :

# Get User's Saved Albums (Spotify) and persist data (ETD : 3 hours)(tests)(Antonio ETD: 4h)
(data must be updated by a Job every 10 minutes)
(the user can also trigger this update on the react app)

## Use openAi to get 5 Similar Artists on each saved album (ETD: 1 to 2 days)(tests)(Antonio ETD: 2 days)
(prompt after an album is saved)
(React APP should have a proper input to prompt (Artists, Genre and Albums) should work based on a simple prompt, **EX: "give me artists that are within the same genre as Cold Play**)(Save all results marked in REACT APP as "valid Results")
(EX: "give me all Madonna Albums" [valid results (clear prompt and persist data) or ignore (clear prompt and results) ])

# Get each Artist from saved albums and store METADATA (ETD : 3 hours)(tests)(Antonio ETD: 4h)

# Add  personal notes each album and artist (ETD : 3 hours)(tests)(Antonio ETD: 3h)
- NOTE: https://guides.rubyonrails.org/association_basics.html#polymorphic-associations

# Log all Calls between Spotify Api, openAi Api, React App (ETD : 3 hours)(tests)(Antonio ETD: 3h)
(source, payload, response)

# share your List with your friends (list of emails triggered by React App)  (ETD : 3 hours)(tests)(Antonio ETD: 3h)

# Get New Releases (ETD : 3 hours)(tests)(Antonio ETD: 3h)
(do not persist data)
(tests -> do not call the api each time)
