FROM alpine:3.17 AS builder

RUN apk add --no-cache \
  boost-dev \
  build-base \
  cmake \
  libuuid \
  python3 \
  tar \
  unzip \ 
  wget

RUN wget https://www.orthanc-server.com/downloads/get.php?path=/orthanc/Orthanc-1.11.2.tar.gz -O Orthanc-1.11.2.tar.gz \
  && tar -xvzf Orthanc-1.11.2.tar.gz \
  && mv Orthanc-1.11.2 Orthanc \
  && mkdir Orthanc/Build

RUN cd Orthanc/Build \
  && cmake -DSTATIC_BUILD=ON -DCMAKE_BUILD_TYPE=Release ../OrthancServer/ \
  && make

RUN apk add --no-cache alpine-conf \
  && setup-timezone -z UTC

FROM alpine:3.17

RUN apk add --no-cache libstdc++

COPY --from=builder /Orthanc/Build/Orthanc /Orthanc/Orthanc
COPY --from=builder /etc/localtime /etc/localtime
COPY config /Orthanc/config

CMD ["./Orthanc/Orthanc", "/Orthanc/config/"]
