FROM alpine:latest

RUN apk add --no-cache lm_sensors msmtp ca-certificates

RUN echo "defaults" > /etc/msmtprc && \
    echo "auth on" >> /etc/msmtprc && \
    echo "tls on" >> /etc/msmtprc && \
    echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> /etc/msmtprc && \
    echo "logfile /var/log/msmtp.log" >> /etc/msmtprc

ENV SMTP_HOST=smtp.gmail.com
ENV SMTP_PORT=587
ENV SMTP_USER=your-email@gmail.com
ENV SMTP_PASS=your-app-password
ENV EMAIL_TO=recipient@example.com

COPY monitor.sh /usr/local/bin/monitor.sh
RUN chmod +x /usr/local/bin/monitor.sh

CMD ["/usr/local/bin/monitor.sh"]

