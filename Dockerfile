FROM oysteinkrog/openscad_nightly

RUN mkdir /build
COPY . /build
RUN cd /build && make 

