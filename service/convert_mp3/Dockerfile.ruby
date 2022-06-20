# Adopted from https://docs.aws.amazon.com/lambda/latest/dg/images-create.html#images-create-from-alt

# From: https://docs.aws.amazon.com/lambda/latest/dg/images-test.html#images-test-add
# To test an image without adding RIE to the image
#
# mkdir -p ~/.aws-lambda-rie && curl -Lo ~/.aws-lambda-rie/aws-lambda-rie \
# https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie \
# && chmod +x ~/.aws-lambda-rie/aws-lambda-rie
#
# For ARM:
#
# https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie-arm64
#
# Run the command
#
# docker run --rm -v ~/.aws-lambda-rie:/aws-lambda -p 9000:8080 \
#  --entrypoint /aws-lambda/aws-lambda-rie record_to_mp3:latest \
#  /usr/local/bundle/bin/aws_lambda_ric app.App::Handler.process
#
# curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

ARG FUNCTION_DIR="/app"

FROM ruby:3.1-alpine as build-image

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache build-base

RUN gem install bundler

ARG FUNCTION_DIR
RUN mkdir -p ${FUNCTION_DIR}
COPY Gemfile Gemfile.lock ${FUNCTION_DIR}
WORKDIR ${FUNCTION_DIR}

ENV BUNDLE_APP_CONFIG="${FUNCTION_DIR}/.bundle"

RUN bundle config --local deployment true && \
    bundle config --local path "vendor/bundle" && \
    bundle config --local without 'development test'

RUN bundle install --jobs 20 --retry 5

RUN rm -rf vendor/bundle/ruby/*/cache/ && find vendor/ -name "*.o" -delete && find vendor/ -name "*.c"

COPY app.rb ${FUNCTION_DIR}


FROM ruby:3.1-alpine

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

ENV BUNDLE_APP_CONFIG="${FUNCTION_DIR}/.bundle"
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache ffmpeg && \
    gem install bundler && \
    gem install aws_lambda_ric

ENTRYPOINT [ "/usr/local/bundle/bin/aws_lambda_ric" ]
CMD [ "app.App::Handler.process" ]
