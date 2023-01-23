FROM swift:5.7

RUN apt-get -q update && apt-get -q install -y \
  git

RUN cd /usr/local && \
  git clone https://github.com/nicklockwood/SwiftFormat && \
  cd SwiftFormat && \
  swift build -c release && \
  ln -s "$(swift build --show-bin-path -c release)/swiftformat" /usr/local/bin/swiftformat
