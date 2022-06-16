FROM public.ecr.aws/lambda/ruby:2.7

RUN yum install -y tar xz
RUN mkdir -p /usr/local/bin/ffmpeg
ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /usr/local/bin/ffmpeg
RUN cd /usr/local/bin/ffmpeg && \
    tar xvf ffmpeg-release-amd64-static.tar.xz && \
    mv ffmpeg-5.0.1-amd64-static/ffmpeg . && \
    ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg

# Copy dependency management file
COPY Gemfile ${LAMBDA_TASK_ROOT}

# Install dependencies under LAMBDA_TASK_ROOT
ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle install

# Copy function code
COPY app.rb ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.LambdaFunction::Handler.process" ]
