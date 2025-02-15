FROM python:3.9-slim

RUN useradd -m user_particle41


WORKDIR /particle41
RUN chown user_particle41:user_particle41 /particle41

USER user_particle41

COPY --chown=user_particle41:user_particle41 . .

RUN pip install  --user -r requirement.txt

EXPOSE 5000


CMD ["python", "particle41.py"]

