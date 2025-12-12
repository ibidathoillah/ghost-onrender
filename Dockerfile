FROM ghost:6-alpine
ENV NODE_ENV=development
COPY init.sh /usr/local/bin/init.sh
COPY ghost/content/themes /opt/custom-themes
RUN chmod +x /usr/local/bin/init.sh
CMD ["/usr/local/bin/init.sh"]
