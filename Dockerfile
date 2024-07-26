#============================================
# 🧑‍💻 Development
#============================================
FROM node:21-alpine as dev
# add the missing shared libraries from alpine base image
RUN apk add --no-cache libc6-compat
# Create app folder
WORKDIR /usr/app

COPY tsconfig.json /usr/app/

# Set to dev environment
ENV NODE_ENV development

# Create non-root user for Docker
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

# Copy source code into app folder
COPY --chown=node:node . .

# Install dependencies
RUN yarn --frozen-lockfile

# Set Docker as a non-root user
USER nestjs

#============================================
# 🏡 Production Build
#============================================
FROM node:21-alpine as build

WORKDIR /usr/app
RUN apk add --no-cache libc6-compat

# Set to production environment
ENV NODE_ENV production

# Re-create non-root user for Docker
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

# In order to run `yarn build` we need access to the Nest CLI.
# Nest CLI is a dev dependency.
COPY --chown=nestjs:nodejs --from=dev /usr/app/node_modules ./node_modules
# Copy source code
COPY --chown=nestjs:nodejs . .

# Generate the production build. The build script runs "nest build" to compile the application.
RUN yarn build

# Install only the production dependencies and clean cache to optimize image size.
RUN yarn --frozen-lockfile --production && yarn cache clean

# Set Docker as a non-root user
USER nestjs

#
# 🚀 Production Server
#
FROM node:21-alpine as prod

WORKDIR /usr/app
RUN apk add --no-cache libc6-compat

# Set to production environment
ENV NODE_ENV production

# Re-create non-root user for Docker
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nestjs

# Copy only the necessary files
COPY --chown=nestjs:nodejs --from=build /usr/app/.env ./.env
COPY --chown=nestjs:nodejs --from=build /usr/app/dist dist
COPY --chown=nestjs:nodejs --from=build /usr/app/node_modules node_modules
COPY --chown=nestjs:nodejs --from=build /usr/app/package.json package.json
COPY --chown=nestjs:nodejs --from=build /usr/app/yarn.lock yarn.lock
COPY --chown=nestjs:nodejs --from=build /usr/app/tsconfig.json tsconfig.json

# Set Docker as non-root user
USER nestjs

EXPOSE 3500

CMD ["sh","-c", "node dist/main.js"]
