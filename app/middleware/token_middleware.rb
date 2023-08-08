class TokenMiddleware
    def initialize(app)
        @app = app
    end

    def call(env)
        # Do something with the request before it reaches the app
        status, headers, response = @app.call(env)

        return [status, headers, response] if response.try(:body).nil?

        # Parse the json string to hash object in order to modify it
        body_object = response.body.strip.empty? ? {} : JSON.parse(response.body)

        # # Set a new key with the name "token" and give it the value of the generated JWT
        body_object["token"] = headers["Authorization"] unless headers["Authorization"].nil?

        # # return the format into json string so that we can return it as the response after we're done modifying it
        body_object = body_object.to_json

        # # Inform the requester that the length of the response has ben extended due to the token key and value being appended
        headers["Content-Length"] = body_object.bytesize

        # Do something with the response before it is sent to the client
        [status, headers, [body_object]]
    end
end